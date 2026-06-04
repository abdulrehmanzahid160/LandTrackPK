# 🏥 SehatConnectPK

> A full-stack digital healthcare platform for Pakistan — connecting patients with doctors through seamless appointment booking, complaint management, and real-time health services.

---

## 📋 Table of Contents

- [About the Project](#about-the-project)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup (Java Spring Boot)](#backend-setup-java-spring-boot)
  - [Frontend Setup (Flutter)](#frontend-setup-flutter)
  - [Database Setup](#database-setup)
- [API Endpoints](#api-endpoints)
- [Screenshots](#screenshots)
- [Contributors](#contributors)

---

## 📌 About the Project

**SehatConnectPK** is a healthcare management application designed for the Pakistani healthcare ecosystem. It allows citizens to book doctor appointments, file complaints, and track their health records — all from a mobile app. The backend exposes a REST API built in Java Spring Boot, while the frontend is a cross-platform Flutter mobile application.

---

## ✨ Features

- 👨‍⚕️ Browse and search doctors by specialization
- 📅 Book, reschedule, and cancel appointments
- 📋 View appointment history and status
- 🏥 Manage patient profiles
- 📝 File and track complaints
- 💬 Complaint comment threads between patients and staff
- 🔒 Role-based access (Patient / Doctor / Admin)
- 📱 Cross-platform mobile app (Android & iOS)

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile Frontend | Flutter (Dart) |
| Backend API | Java Spring Boot |
| Database | MySQL |
| ORM | Spring Data JPA / Hibernate |
| Architecture | REST API |
| Build Tool | Maven |

**Languages used:**
- Dart — 61.3%
- Java — 18.1%
- C++ — 10.3% (Flutter native)
- CMake — 8.2% (Flutter build)
- Swift / C — 1.4% (Flutter iOS/native)

---

## 📁 Project Structure

```
SehatConnectPK/
│
├── data/                          # SQL scripts and seed data
│
├── sehatconnect_backend_modified/ # Java Spring Boot Backend
│   └── src/main/java/
│       ├── controller/            # REST API Controllers
│       ├── model/                 # Entity classes (DB tables)
│       ├── repository/            # JPA Repositories
│       ├── service/               # Business logic layer
│       └── SehatConnectApplication.java
│
├── sehatconnect_flutter/          # Flutter Mobile Frontend
│   ├── lib/
│   │   ├── screens/               # UI screens
│   │   ├── models/                # Data models
│   │   ├── services/              # API call services
│   │   └── main.dart              # App entry point
│   └── pubspec.yaml
│
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

- Java JDK 17+
- Maven 3.8+
- Flutter SDK 3.0+
- MySQL 8.0+
- Android Studio or VS Code
- Postman (optional, for API testing)

---

### Backend Setup (Java Spring Boot)

1. **Clone the repository**
   ```bash
   git clone https://github.com/userproxy2160-create/SehatConnectPK.git
   cd SehatConnectPK/sehatconnect_backend_modified
   ```

2. **Configure the database**

   Open `src/main/resources/application.properties` and update:
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/sehatconnect
   spring.datasource.username=your_mysql_username
   spring.datasource.password=your_mysql_password
   spring.jpa.hibernate.ddl-auto=update
   server.port=8080
   ```

3. **Build and run**
   ```bash
   mvn clean install
   mvn spring-boot:run
   ```

4. Backend will be running at: `http://localhost:8080`

---

### Frontend Setup (Flutter)

1. **Navigate to the Flutter project**
   ```bash
   cd SehatConnectPK/sehatconnect_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API base URL**

   In `lib/services/api_service.dart` (or equivalent), set:
   ```dart
   const String baseUrl = 'http://10.0.2.2:8080'; // Android emulator
   // or use your machine's local IP for a physical device
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

### Database Setup

1. Create a MySQL database:
   ```sql
   CREATE DATABASE sehatconnect;
   ```

2. Run the SQL scripts from the `data/` folder in order to create tables and seed initial data.

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/doctors` | Get all doctors |
| GET | `/api/doctors/{id}` | Get doctor by ID |
| POST | `/api/appointments` | Book an appointment |
| GET | `/api/appointments/{id}` | Get appointment details |
| PUT | `/api/appointments/{id}` | Update appointment status |
| DELETE | `/api/appointments/{id}` | Cancel appointment |
| POST | `/api/complaints` | File a complaint |
| GET | `/api/complaints/{id}` | Get complaint details |
| POST | `/api/complaints/{id}/comments` | Add comment to complaint |
| GET | `/api/patients/{id}` | Get patient profile |

---

## 👥 Contributors

| Name | Role |
|------|------|
| [userproxy2160-create](https://github.com/userproxy2160-create) | Full Stack — Flutter Frontend, Java Backend & Database |

---

## 📄 License

This project is for academic purposes — developed as part of a university project in Pakistan.

---

> Built with ❤️ for Pakistan's healthcare system 🇵🇰
