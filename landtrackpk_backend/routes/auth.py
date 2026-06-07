from flask import Blueprint, request, jsonify
from db import get_connection

auth_bp = Blueprint('auth', __name__)


@auth_bp.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        cnic = data.get('cnic')
        password = data.get('password')
        role = data.get('role')

        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT CitizenID, FullName, Role FROM Citizens WHERE CNIC = ? AND PasswordHash = ? AND Role = ?",
            (cnic, password, role)
        )
        row = cursor.fetchone()
        conn.close()

        if row:
            return jsonify({
                'success': True,
                'citizen_id': row.CitizenID,
                'full_name': row.FullName,
                'role': row.Role
            })
        else:
            return jsonify({'success': False, 'message': 'Invalid credentials'}), 401

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@auth_bp.route('/add-citizen', methods=['POST'])
def add_citizen():
    try:
        data = request.get_json()
        full_name = data.get('full_name')
        cnic = data.get('cnic')
        phone = data.get('phone')          # primary phone number
        street = data.get('street', '')
        city = data.get('city', '')
        district = data.get('district', '')
        postal_code = data.get('postal_code', '')
        password = data.get('password')
        role = data.get('role')

        conn = get_connection()
        cursor = conn.cursor()

        # Insert into Citizens and retrieve new CitizenID safely
        cursor.execute('SET NOCOUNT ON; INSERT INTO Citizens (FullName, CNIC, Street, City, District, PostalCode, PasswordHash, Role) VALUES (?, ?, ?, ?, ?, ?, ?, ?); SELECT SCOPE_IDENTITY();',
                       (full_name, cnic, street, city, district, postal_code, password, role))
        citizen_id = int(cursor.fetchone()[0])

        # Insert phone number into CitizenPhones if provided
        if phone:
            cursor.execute(
                "INSERT INTO CitizenPhones (CitizenID, PhoneNumber) VALUES (?, ?)",
                (citizen_id, phone)
            )

        conn.commit()
        conn.close()

        return jsonify({'success': True, 'citizen_id': citizen_id})

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@auth_bp.route('/citizens', methods=['GET'])
def get_citizens():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT CitizenID, FullName, CNIC, Role FROM Citizens ORDER BY FullName")
        rows = cursor.fetchall()
        conn.close()

        citizens = []
        for r in rows:
            citizens.append({
                'citizen_id': r.CitizenID,
                'full_name': r.FullName,
                'cnic': r.CNIC,
                'role': r.Role
            })
        return jsonify(citizens)
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@auth_bp.route('/citizen/<int:citizen_id>', methods=['DELETE'])
def delete_citizen(citizen_id):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Delete related phone numbers first
        cursor.execute("DELETE FROM CitizenPhones WHERE CitizenID = ?", (citizen_id,))
        # Then delete the citizen
        cursor.execute("DELETE FROM Citizens WHERE CitizenID = ?", (citizen_id,))
        
        conn.commit()
        conn.close()
        
        return jsonify({'success': True, 'message': 'User deleted successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500
