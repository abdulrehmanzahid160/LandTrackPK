from flask import Blueprint, jsonify
from db import get_connection

land_bp = Blueprint('land', __name__)


@land_bp.route('/property/<plot_number>', methods=['GET'])
def get_property(plot_number):
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Get plot details + current owner
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

        if not row:
            conn.close()
            return jsonify({'success': False, 'message': 'Plot not found'}), 404

        # Get ownership history
        cursor.execute("""
            SELECT prev.FullName AS previous_owner, nw.FullName AS new_owner, oh.TransferDate
            FROM OwnershipHistory oh
            JOIN Citizens prev ON oh.PreviousCitizenID = prev.CitizenID
            JOIN Citizens nw ON oh.NewCitizenID = nw.CitizenID
            JOIN LandParcels lp ON oh.PlotID = lp.PlotID
            WHERE lp.PlotNumber = ?
            ORDER BY oh.TransferDate DESC
        """, (plot_number,))
        history_rows = cursor.fetchall()
        history = []
        for h in history_rows:
            history.append({
                'previous_owner': h.previous_owner,
                'new_owner': h.new_owner,
                'transfer_date': str(h.TransferDate)
            })

        conn.close()

        return jsonify({
            'success': True,
            'plot_number': row.PlotNumber,
            'area': float(row.Area),
            'area_unit': row.AreaUnit,
            'land_type': row.LandType,
            'district': row.District,
            'tehsil': row.Tehsil,
            'registered_date': str(row.RegisteredDate),
            'owner_name': row.OwnerName,
            'owner_cnic': row.OwnerCNIC.strip() if row.OwnerCNIC else None,
            'acquired_date': str(row.AcquiredDate) if row.AcquiredDate else None,
            'history': history
        })

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@land_bp.route('/register-land', methods=['POST'])
def register_land():
    try:
        from flask import request
        data = request.get_json()
        plot_number = data.get('plot_number')
        area = data.get('area')
        area_unit = data.get('area_unit')
        land_type = data.get('land_type')
        district = data.get('district')
        tehsil = data.get('tehsil')
        owner_cnic = data.get('owner_cnic')

        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            "EXEC sp_RegisterLand ?, ?, ?, ?, ?, ?, ?",
            (plot_number, area, area_unit, district, tehsil, land_type, owner_cnic)
        )
        row = cursor.fetchone()
        conn.commit()
        conn.close()

        if row:
            return jsonify({'success': True, 'message': row.Message, 'plot_id': row.PlotID})
        return jsonify({'success': True, 'message': 'Land registered successfully'})

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@land_bp.route('/dashboard/stats', methods=['GET'])
def dashboard_stats():
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT COUNT(*) FROM LandParcels")
        total_plots = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM TransferRequests WHERE Status = 'Pending'")
        pending_transfers = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM Disputes WHERE Status = 'Open'")
        active_disputes = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM Citizens")
        total_citizens = cursor.fetchone()[0]

        conn.close()

        return jsonify({
            'total_plots': total_plots,
            'pending_transfers': pending_transfers,
            'active_disputes': active_disputes,
            'total_citizens': total_citizens
        })

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@land_bp.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'message': 'LandTrack PK API is running'})
