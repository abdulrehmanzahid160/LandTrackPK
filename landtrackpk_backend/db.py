import pyodbc

def get_connection():
    """
    Establishes a connection to the SQL Server database.
    Tries multiple candidate connection strings for local SQLEXPRESS or default instances
    using either ODBC Driver 17 or 18 to ensure it works out-of-the-box.
    """
    connection_strings = [
        # ODBC Driver 17 — known working on this machine
        'DRIVER={ODBC Driver 17 for SQL Server};SERVER=.\\SQLEXPRESS;DATABASE=LandTrackPK;Trusted_Connection=yes;Connection Timeout=5;',
        'DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost\\SQLEXPRESS;DATABASE=LandTrackPK;Trusted_Connection=yes;Connection Timeout=5;',
        'DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;DATABASE=LandTrackPK;Trusted_Connection=yes;Connection Timeout=5;',
        
        # ODBC Driver 18 Candidates (requiring TrustServerCertificate)
        'DRIVER={ODBC Driver 18 for SQL Server};SERVER=.\\SQLEXPRESS;DATABASE=LandTrackPK;Trusted_Connection=yes;TrustServerCertificate=yes;Connection Timeout=5;',
        'DRIVER={ODBC Driver 18 for SQL Server};SERVER=localhost\\SQLEXPRESS;DATABASE=LandTrackPK;Trusted_Connection=yes;TrustServerCertificate=yes;Connection Timeout=5;',
        'DRIVER={ODBC Driver 18 for SQL Server};SERVER=localhost;DATABASE=LandTrackPK;Trusted_Connection=yes;TrustServerCertificate=yes;Connection Timeout=5;',
    ]
    
    last_err = None
    for conn_str in connection_strings:
        try:
            conn = pyodbc.connect(conn_str)
            return conn
        except Exception as e:
            last_err = e
            continue
            
    # If all failed, raise the final exception
    if last_err:
        raise Exception(f"Failed to connect to SQL Server. Tested connection strings: {connection_strings}. Last error: {str(last_err)}")
    raise Exception("No connection strings available to connect.")
