# LandTrack PK

LandTrack PK is a comprehensive land record management system designed for Pakistan. It provides a secure and transparent digital platform for citizens to manage their properties and for land officers to oversee land operations efficiently.

## Features

* **Role-Based Access:** Dedicated interfaces for Citizens and Land Officers.
* **Property Management:** Citizens can view their land ownership details and obtain a digital *Fard* (Land Record Document).
* **Transfer Requests:** Securely initiate and approve property ownership transfers between citizens.
* **Dispute Resolution:** Citizens can file land disputes which are tracked and managed by officers.
* **Service Booking:** Book in-person appointments at local service centers.
* **Complaints System:** File and track complaints with a built-in comment system.

## Technology Stack

* **Frontend:** Flutter (Mobile/Web)
* **Backend:** Python with Flask
* **Database:** Microsoft SQL Server

## Project Structure

* `/landtrackpk_frontend/` - Contains the Flutter application.
* `/landtrackpk_backend/` - Contains the Flask API backend.
* `landtrackpk.sql` - The SQL script to initialize the database schema, stored procedures, triggers, and sample data.

## Setup Instructions

### 1. Database Setup
1. Open **SQL Server Management Studio (SSMS)**.
2. Open the `landtrackpk.sql` file and click **Execute**. 
> **Important:** Only run this script **once** to set up the database. Running it again will completely wipe all your saved data and reset the database back to the default sample records. To view your data, use a `SELECT` query instead.

### 2. Backend Setup
1. Open a terminal and navigate to the backend directory:
   ```bash
   cd landtrackpk_backend
   ```
2. Install dependencies (e.g., `flask`, `pyodbc`, `flask-cors`):
   ```bash
   pip install -r requirements.txt
   ```
3. Run the backend server:
   ```bash
   python app.py
   ```
   *The server will start on `http://localhost:5000`.*

### 3. Frontend Setup
1. Open a terminal and navigate to the frontend directory:
   ```bash
   cd landtrackpk_frontend
   ```
2. Retrieve packages:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```
   *Note: If you are running the app on a physical mobile device, make sure to update the `_mobileBaseUrl` in `lib/constants.dart` to match your computer's local Wi-Fi IP address (e.g., `192.168.x.x`).*
