# Cab Booking System

A full-stack, database-driven ride-hailing application designed to demonstrate core Database Management System (DBMS) architecture, concurrency control, and real-time state synchronization.

## 🚀 Core Features
* **Automated Ride Matching & Routing:** Dynamic fare calculation powered by a MySQL associative distance matrix, eliminating the need for external mapping APIs.
* **Transactional State Management:** DML-enforced concurrency control to track driver availability (Available/Busy) and prevent double-booking anomalies during simultaneous requests.
* **Real-Time Dashboards:** Synchronized Jinja2 client and driver interfaces utilizing automated DOM refresh mechanisms for instant ride lifecycle updates (Pending ➔ Accepted ➔ Completed).
* **Relational Data Integrity:** Strictly normalized database schema employing primary/foreign key constraints and ENUM validations to prevent orphaned records.

## 💻 Tech Stack
* **Backend Infrastructure:** Python 3, Flask
* **Database Tier:** MySQL (DDL/DML Operations, Parameterized Queries)
* **Frontend Interface:** HTML5, CSS3, Jinja2 Templating Engine
* **Integration & Middleware:** `mysql-connector-python`

## ⚙️ Architecture & Database Design
The application operates on a classic 3-tier architecture with a heavily optimized data layer:
* **Master Entities:** Independent tracking of `Users`, `Drivers`, and `Locations`.
* **Associative Matrix:** A dedicated `Routes` table mapping real-world distances between nodes (e.g., Dighori to YCCE Campus) for relational fare lookups.
* **Lifecycle Tracking:** The `Rides` transactional table binds passengers, drivers, and spatial data while strictly enforcing status state machines to protect data integrity.
