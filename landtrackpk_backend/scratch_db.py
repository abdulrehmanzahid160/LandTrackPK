import pyodbc
from db import get_connection

try:
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT CitizenID, FullName, CNIC, PasswordHash, Role FROM Citizens")
    rows = cursor.fetchall()
    print("Citizens in DB:")
    for row in rows:
        print(f"ID: {row[0]}, Name: {row[1]}, CNIC: '{row[2]}', Pass: '{row[3]}', Role: '{row[4]}'")
    conn.close()
except Exception as e:
    print("Error:", e)
