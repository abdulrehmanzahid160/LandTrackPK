from flask import Blueprint, jsonify, request
from db import get_connection
import random

citizen_bp = Blueprint('citizen', __name__)


@citizen_bp.route('/citizen/<cnic>', methods=['GET'])
def get_citizen(cnic):
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Get citizen info with composite address
        cursor.execute(
            "SELECT CitizenID, FullName, CNIC, Street, City, District, PostalCode, Role FROM Citizens WHERE CNIC = ?",
            (cnic,)
        )
        row = cursor.fetchone()
        if not row:
            conn.close()
            return jsonify({'success': False, 'message': 'Citizen not found'}), 404

        citizen_id = row.CitizenID

        # Get phone numbers (multivalued attribute)
        cursor.execute(
            "SELECT PhoneNumber FROM CitizenPhones WHERE CitizenID = ?",
            (citizen_id,)
        )
        phones = [p.PhoneNumber for p in cursor.fetchall()]

        # Get properties owned
        cursor.execute("""
            SELECT lp.PlotNumber, lp.Area, lp.AreaUnit, lp.District, lp.LandType
            FROM Ownership o
            JOIN LandParcels lp ON o.PlotID = lp.PlotID
            WHERE o.CitizenID = ?
        """, (citizen_id,))
        properties = []
        for p in cursor.fetchall():
            properties.append({
                'plot_number': p.PlotNumber,
                'area': float(p.Area),
                'area_unit': p.AreaUnit,
                'district': p.District,
                'land_type': p.LandType
            })

        conn.close()

        return jsonify({
            'success': True,
            'citizen_id': citizen_id,
            'full_name': row.FullName,
            'cnic': row.CNIC.strip(),
            'street': row.Street or '',
            'city': row.City or '',
            'district': row.District or '',
            'postal_code': row.PostalCode or '',
            'phones': phones,
            'role': row.Role,
            'properties': properties
        })

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@citizen_bp.route('/dispute/create', methods=['POST'])
def create_dispute():
    """
    Files a new land dispute against a specific plot.
    """
    try:
        data = request.get_json()
        plot_number = data.get('plot_number')
        citizen_id = data.get('citizen_id')
        description = data.get('description')

        conn = get_connection()
        cursor = conn.cursor()

        # Resolve PlotID from PlotNumber
        cursor.execute("SELECT PlotID FROM LandParcels WHERE PlotNumber = ?", (plot_number,))
        plot_row = cursor.fetchone()
        if not plot_row:
            conn.close()
            return jsonify({'success': False, 'message': 'Plot not found with that plot number'}), 404
        plot_id = plot_row.PlotID

        cursor.execute("""
            INSERT INTO Disputes (PlotID, FiledByCitizenID, Description, Status, FiledDate)
            VALUES (?, ?, ?, 'Open', GETDATE())
        """, (plot_id, citizen_id, description))

        conn.commit()
        conn.close()

        return jsonify({'success': True, 'message': 'Dispute filed successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@citizen_bp.route('/disputes', methods=['GET'])
def get_disputes():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT d.DisputeID, lp.PlotNumber, c.FullName AS FiledBy,
                   d.Description, d.Status, d.FiledDate
            FROM Disputes d
            JOIN LandParcels lp ON d.PlotID = lp.PlotID
            JOIN Citizens c ON d.FiledByCitizenID = c.CitizenID
            ORDER BY d.FiledDate DESC
        """)
        rows = cursor.fetchall()
        conn.close()

        disputes = []
        for r in rows:
            disputes.append({
                'dispute_id': r.DisputeID,
                'plot_number': r.PlotNumber,
                'filed_by': r.FiledBy,
                'description': r.Description,
                'status': r.Status,
                'filed_date': str(r.FiledDate)
            })

        return jsonify(disputes)

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@citizen_bp.route('/fard/<plot_number>', methods=['GET'])
def get_fard(plot_number):
    """
    Retrieves high-fidelity Fard details for a specific plot.
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT lp.PlotNumber, lp.Area, lp.AreaUnit, lp.LandType,
                   lp.District, lp.Tehsil, lp.RegisteredDate,
                   c.FullName AS OwnerName, c.CNIC AS OwnerCNIC, o.AcquiredDate
            FROM LandParcels lp
            LEFT JOIN Ownership o ON lp.PlotID = o.PlotID
            LEFT JOIN Citizens c ON o.CitizenID = c.CitizenID
            WHERE lp.PlotNumber = ?
        """, (plot_number,))
        row = cursor.fetchone()
        conn.close()

        if not row:
            return jsonify({'success': False, 'message': 'Property not found'}), 404

        return jsonify({
            'success': True,
            'plot_number': row.PlotNumber,
            'area': float(row.Area),
            'area_unit': row.AreaUnit,
            'land_type': row.LandType,
            'district': row.District,
            'tehsil': row.Tehsil,
            'registered_date': str(row.RegisteredDate),
            'owner_name': row.OwnerName or 'Government of Pakistan',
            'owner_cnic': row.OwnerCNIC.strip() if row.OwnerCNIC else '',
            'acquired_date': str(row.AcquiredDate) if row.AcquiredDate else ''
        })
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@citizen_bp.route('/service-history/<int:citizen_id>', methods=['GET'])
def get_service_history(citizen_id):
    """
    Retrieves full service history including service visits and land transactions.
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Get appointments (Visits)
        cursor.execute("""
            SELECT AppointmentID, ServiceCenter, Tehsil, Reason, AppointmentDate, AppointmentTime, TokenNumber, Status
            FROM Appointments
            WHERE CitizenID = ?
            ORDER BY AppointmentDate DESC
        """, (citizen_id,))
        visits_rows = cursor.fetchall()
        visits = []
        for r in visits_rows:
            visits.append({
                'appointment_id': r.AppointmentID,
                'service_center': r.ServiceCenter,
                'tehsil': r.Tehsil,
                'reason': r.Reason,
                'appointment_date': str(r.AppointmentDate),
                'appointment_time': r.AppointmentTime,
                'token_number': r.TokenNumber,
                'status': r.Status
            })

        # Get transactions (transfers involving this citizen)
        cursor.execute("""
            SELECT tr.TransferID, lp.PlotNumber, lp.District,
                   from_c.FullName AS FromOwner, from_c.CNIC AS FromCNIC,
                   to_c.FullName AS ToOwner, to_c.CNIC AS ToCNIC,
                   tr.Reason, tr.Status, tr.RequestDate
               FROM TransferRequests tr
               JOIN LandParcels lp ON tr.PlotID = lp.PlotID
               JOIN Citizens from_c ON tr.FromCitizenID = from_c.CitizenID
               JOIN Citizens to_c ON tr.ToCitizenID = to_c.CitizenID
               WHERE tr.FromCitizenID = ? OR tr.ToCitizenID = ?
               ORDER BY tr.RequestDate DESC
        """, (citizen_id, citizen_id))
        trans_rows = cursor.fetchall()
        transactions = []
        for r in trans_rows:
            transactions.append({
                'transfer_id': r.TransferID,
                'plot_number': r.PlotNumber,
                'district': r.District,
                'from_owner': r.FromOwner,
                'from_cnic': r.FromCNIC.strip(),
                'to_owner': r.ToOwner,
                'to_cnic': r.ToCNIC.strip(),
                'reason': r.Reason,
                'status': r.Status,
                'request_date': str(r.RequestDate)
            })

        conn.close()
        return jsonify({
            'success': True,
            'visits': visits,
            'transactions': transactions
        })
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@citizen_bp.route('/book-appointment', methods=['POST'])
def book_appointment():
    """
    Books an appointment and returns a unique visit token number.
    """
    try:
        data = request.get_json()
        citizen_id = data.get('citizen_id')
        service_center = data.get('service_center')
        tehsil = data.get('tehsil')
        reason = data.get('reason')
        date = data.get('appointment_date')
        time = data.get('appointment_time')

        token_number = str(random.randint(100, 1500))

        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO Appointments (CitizenID, ServiceCenter, Tehsil, Reason, AppointmentDate, AppointmentTime, TokenNumber, Status)
            VALUES (?, ?, ?, ?, ?, ?, ?, 'Scheduled')
        """, (citizen_id, service_center, tehsil, reason, date, time, token_number))
        conn.commit()
        conn.close()

        return jsonify({
            'success': True,
            'message': 'Appointment booked successfully',
            'token_number': token_number
        })
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@citizen_bp.route('/complaints/<int:citizen_id>', methods=['GET'])
def get_complaints(citizen_id):
    """
    Retrieves all complaints filed by a citizen.
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT ComplaintID, ComplaintType, Details, Status, SubmittedDate, AttachmentPath
            FROM Complaints
            WHERE CitizenID = ?
            ORDER BY SubmittedDate DESC
        """, (citizen_id,))
        rows = cursor.fetchall()
        conn.close()

        complaints = []
        for r in rows:
            complaints.append({
                'complaint_id': r.ComplaintID,
                'complaint_type': r.ComplaintType,
                'details': r.Details,
                'status': r.Status,
                'submitted_date': str(r.SubmittedDate),
                'attachment_path': r.AttachmentPath or ''
            })

        return jsonify({'success': True, 'complaints': complaints})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@citizen_bp.route('/complaint/<int:complaint_id>', methods=['GET'])
def get_complaint_details(complaint_id):
    """
    Retrieves details for a specific complaint, including full chat history.
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Get base complaint
        cursor.execute("""
            SELECT ComplaintID, ComplaintType, Details, Status, SubmittedDate, AttachmentPath, CitizenID
            FROM Complaints
            WHERE ComplaintID = ?
        """, (complaint_id,))
        r = cursor.fetchone()
        if not r:
            conn.close()
            return jsonify({'success': False, 'message': 'Complaint not found'}), 404

        complaint_info = {
            'complaint_id': r.ComplaintID,
            'complaint_type': r.ComplaintType,
            'details': r.Details,
            'status': r.Status,
            'submitted_date': str(r.SubmittedDate),
            'attachment_path': r.AttachmentPath or '',
            'citizen_id': r.CitizenID
        }

        # Get comments
        cursor.execute("""
            SELECT CommentID, SenderType, SenderName, CommentText, CommentDate
            FROM ComplaintComments
            WHERE ComplaintID = ?
            ORDER BY CommentDate ASC
        """, (complaint_id,))
        comment_rows = cursor.fetchall()
        comments = []
        for cr in comment_rows:
            comments.append({
                'comment_id': cr.CommentID,
                'sender_type': cr.SenderType,
                'sender_name': cr.SenderName,
                'comment_text': cr.CommentText,
                'comment_date': str(cr.CommentDate)
            })

        conn.close()
        return jsonify({
            'success': True,
            'complaint': complaint_info,
            'comments': comments
        })
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@citizen_bp.route('/complaint/create', methods=['POST'])
def create_complaint():
    """
    Files a new support complaint ticket.
    """
    try:
        data = request.get_json()
        citizen_id = data.get('citizen_id')
        complaint_type = data.get('complaint_type')
        details = data.get('details')
        attachment_path = data.get('attachment_path', '')

        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO Complaints (CitizenID, ComplaintType, Details, Status, SubmittedDate, AttachmentPath)
            OUTPUT INSERTED.ComplaintID
            VALUES (?, ?, ?, 'Open', GETDATE(), ?)
        """, (citizen_id, complaint_type, details, attachment_path))
        complaint_id = int(cursor.fetchone()[0])

        # Get citizen name to post initial comment
        cursor.execute("""
            SELECT FullName FROM Citizens WHERE CitizenID = ?
        """, (citizen_id,))
        name_row = cursor.fetchone()
        full_name = name_row.FullName if name_row else 'Complainant'

        cursor.execute("""
            INSERT INTO ComplaintComments (ComplaintID, SenderType, SenderName, CommentText, CommentDate)
            VALUES (?, 'Complainant', ?, ?, GETDATE())
        """, (complaint_id, full_name, details))

        conn.commit()
        conn.close()

        return jsonify({
            'success': True,
            'message': 'Complaint registered successfully',
            'complaint_id': complaint_id
        })
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@citizen_bp.route('/complaint/comment', methods=['POST'])
def add_complaint_comment():
    """
    Adds a new comment thread bubble to an active complaint ticket.
    """
    try:
        data = request.get_json()
        complaint_id = data.get('complaint_id')
        sender_type = data.get('sender_type') # 'Complainant' or 'ServiceRep'
        sender_name = data.get('sender_name')
        comment_text = data.get('comment_text')

        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO ComplaintComments (ComplaintID, SenderType, SenderName, CommentText, CommentDate)
            VALUES (?, ?, ?, ?, GETDATE())
        """, (complaint_id, sender_type, sender_name, comment_text))
        conn.commit()
        conn.close()

        return jsonify({
            'success': True,
            'message': 'Comment added successfully'
        })
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@citizen_bp.route('/dispute/resolve/<int:dispute_id>', methods=['POST'])
def resolve_dispute(dispute_id):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("UPDATE Disputes SET Status = 'Resolved' WHERE DisputeID = ?", (dispute_id,))
        conn.commit()
        conn.close()
        return jsonify({'success': True, 'message': 'Dispute resolved successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500
