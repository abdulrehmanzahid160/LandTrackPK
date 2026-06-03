from flask import Blueprint, request, jsonify
from db import get_connection

transfers_bp = Blueprint('transfers', __name__)


@transfers_bp.route('/transfer-request', methods=['POST'])
def transfer_request():
    try:
        data = request.get_json()
        plot_number = data.get('plot_number')
        from_cnic = data.get('from_cnic')
        to_cnic = data.get('to_cnic')
        reason = data.get('reason', '')

        conn = get_connection()
        cursor = conn.cursor()

        # Lookup PlotID
        cursor.execute("SELECT PlotID FROM LandParcels WHERE PlotNumber = ?", (plot_number,))
        plot_row = cursor.fetchone()
        if not plot_row:
            conn.close()
            return jsonify({'success': False, 'message': 'Plot not found'}), 404
        plot_id = plot_row.PlotID

        # Lookup FromCitizenID
        cursor.execute("SELECT CitizenID FROM Citizens WHERE CNIC = ?", (from_cnic,))
        from_row = cursor.fetchone()
        if not from_row:
            conn.close()
            return jsonify({'success': False, 'message': 'From Citizen CNIC not found'}), 404
        from_citizen_id = from_row.CitizenID

        # Lookup ToCitizenID
        cursor.execute("SELECT CitizenID FROM Citizens WHERE CNIC = ?", (to_cnic,))
        to_row = cursor.fetchone()
        if not to_row:
            conn.close()
            return jsonify({'success': False, 'message': 'To Citizen CNIC not found'}), 404
        to_citizen_id = to_row.CitizenID

        cursor.execute(
            """INSERT INTO TransferRequests (PlotID, FromCitizenID, ToCitizenID, Reason)
               OUTPUT INSERTED.TransferID
               VALUES (?, ?, ?, ?)""",
            (plot_id, from_citizen_id, to_citizen_id, reason)
        )
        transfer_id = int(cursor.fetchone()[0])

        conn.commit()
        conn.close()

        return jsonify({'success': True, 'transfer_id': transfer_id})

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@transfers_bp.route('/transfers/pending', methods=['GET'])
def pending_transfers():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM vw_PendingTransfers ORDER BY RequestDate DESC")
        rows = cursor.fetchall()
        conn.close()

        transfers = []
        for r in rows:
            transfers.append({
                'transfer_id': r.TransferID,
                'plot_number': r.PlotNumber,
                'from_owner': r.FromOwner,
                'to_owner': r.ToOwner,
                'reason': r.Reason,
                'request_date': str(r.RequestDate)
            })

        return jsonify(transfers)

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@transfers_bp.route('/approve-transfer/<int:transfer_id>', methods=['POST'])
def approve_transfer(transfer_id):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_TransferOwnership ?", (transfer_id,))
        row = cursor.fetchone()
        conn.commit()
        conn.close()

        if row:
            return jsonify({'success': True, 'message': row.Message})
        return jsonify({'success': True, 'message': 'Transfer approved successfully'})

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500
