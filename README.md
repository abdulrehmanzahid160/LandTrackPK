# 🚀 LandTrack PK

**Author:** Abdul Rehman,Fatima Tariq,Hafsa Khan

LandTrack PK is a comprehensive land record management system designed for Pakistan.  
It provides a secure and transparent digital platform for citizens to manage their properties and for land officers to efficiently oversee land operations.

---

## ✨ Features

- 🔐 Role-Based Access (Citizens & Land Officers)
- 🏠 Property Management (View ownership details & digital Fard)
- 🔄 Transfer Requests (Secure property ownership transfers)
- ⚖️ Dispute Resolution (File and track land disputes)
- 📅 Service Booking (Appointment scheduling system)
- 📝 Complaints System (With tracking and comments)

---

## 🛠️ Technology Stack

- **Frontend:** Flutter (Mobile & Web)
- **Backend:** Python (Flask)
- **Database:** Microsoft SQL Server

---

## 📁 Project Structure

/landtrackpk_frontend/ → Flutter application  
/landtrackpk_backend/ → Flask API backend  
landtrackpk.sql → Database schema, stored procedures, triggers & sample data  

---

## ⚙️ Setup Instructions

### 1️⃣ Database Setup
- Open **SQL Server Management Studio (SSMS)**
- Run `landtrackpk.sql`
- ⚠️ Run only once (re-running will reset database)

---

### 2️⃣ Backend Setup

cd landtrackpk_backend  
pip install -r requirements.txt  
python app.py  

Backend runs at:  
http://localhost:5000  

---

### 3️⃣ Frontend Setup

cd landtrackpk_frontend  
flutter pub get  
flutter run  

If using a physical device:  
Update `_mobileBaseUrl` in  
lib/constants.dart  

Use your system IP:  
192.168.x.x  

---

## 🎯 Project Goal

The goal of this project is to modernize land record systems by making them:

- Transparent  
- Secure  
- Digitally accessible  
- Efficient for citizens and land officers  

---

## 👨‍💻 Author
 
Built with ❤️ using Flutter + Flask + SQL Server
