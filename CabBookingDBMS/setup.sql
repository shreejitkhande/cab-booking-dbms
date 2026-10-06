CREATE DATABASE cab_booking;
USE cab_booking;


-- 2. Users Entity
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

-- 3. Drivers Entity
CREATE TABLE Drivers (
    driver_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    availability_status ENUM('Available', 'Busy') DEFAULT 'Available'
);

-- 4. Vehicles Entity
CREATE TABLE Vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    driver_id INT,
    model VARCHAR(50),
    plate_number VARCHAR(20),
    FOREIGN KEY (driver_id) REFERENCES Drivers(driver_id)
);

INSERT INTO Drivers (name, availability_status) VALUES 
('Ramesh', 'Available'), ('Suresh', 'Available');

INSERT INTO Vehicles (driver_id, model, plate_number) VALUES 
(1, 'Tata Nexon', 'MH-31-AB-1234'), (2, 'Maruti Dzire', 'MH-31-CD-5678');

-- ---------------------------------------------------------------------------------------------------
-- 1. Updated Locations Table (No X/Y coordinates)
CREATE TABLE Locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- 2. New Routes Table (Stores exact kilometers)
CREATE TABLE Routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    source_id INT,
    destination_id INT,
    distance_km DECIMAL(10,2),
    FOREIGN KEY (source_id) REFERENCES Locations(location_id),
    FOREIGN KEY (destination_id) REFERENCES Locations(location_id)
);

-- Recreate Rides and Payments exactly as they were before
CREATE TABLE Rides (
    ride_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    pickup_loc_id INT,
    dropoff_loc_id INT,
    driver_id INT NULL,
    distance DECIMAL(10,2),
    fare DECIMAL(10,2),
    status ENUM('Pending', 'Accepted', 'Rejected', 'Completed') DEFAULT 'Pending',
    FOREIGN KEY (pickup_loc_id) REFERENCES Locations(location_id),
    FOREIGN KEY (dropoff_loc_id) REFERENCES Locations(location_id),
    FOREIGN KEY (driver_id) REFERENCES Drivers(driver_id)
);

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    ride_id INT,
    amount DECIMAL(10,2),
    payment_status ENUM('Pending', 'Completed') DEFAULT 'Pending',
    FOREIGN KEY (ride_id) REFERENCES Rides(ride_id)
);

-- --- DML: Insert Nagpur Locations ---
INSERT INTO Locations (name) VALUES 
('Dighori'), 
('YCCE Campus'), 
('Sitabuldi'), 
('Dharampeth'),
('Manewada Square');

-- --- DML: Insert Exact Distances (in km) ---
INSERT INTO Routes (source_id, destination_id, distance_km) VALUES 
(1, 2, 18.0), -- Dighori to YCCE
(2, 1, 18.0), -- YCCE to Dighori
(1, 3, 7.5),  -- Dighori to Sitabuldi
(3, 1, 7.5),  -- Sitabuldi to Dighori
(3, 2, 14.0), -- Sitabuldi to YCCE
(2, 3, 14.0); -- YCCE to Sitabuldi
-- (Tanmay can help populate the rest of the combinations for the other locations!)

-- ------------------------------------------------------------------------------------

USE cab_booking;

-- Clear old data first to avoid conflicts
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Payments;
TRUNCATE TABLE Rides;
TRUNCATE TABLE Routes;
TRUNCATE TABLE Vehicles;
TRUNCATE TABLE Drivers;
SET FOREIGN_KEY_CHECKS = 1;

-- Insert 3 Drivers
INSERT INTO Drivers (name, availability_status) VALUES 
('Ramesh', 'Available'), 
('Suresh', 'Available'), 
('Mahesh', 'Available');

-- Insert 3 Vehicles
INSERT INTO Vehicles (driver_id, model, plate_number) VALUES 
(1, 'Tata Nexon', 'MH-31-AB-1234'), 
(2, 'Maruti Dzire', 'MH-31-CD-5678'),
(3, 'Hyundai Aura', 'MH-31-EF-9012');

-- Insert all combinations for the 5 Nagpur Locations
-- 1: Dighori, 2: YCCE Campus, 3: Sitabuldi, 4: Dharampeth, 5: Manewada Square
INSERT INTO Routes (source_id, destination_id, distance_km) VALUES 
-- From Dighori
(1, 2, 18.0), (1, 3, 7.5), (1, 4, 9.0), (1, 5, 4.0),
-- From YCCE
(2, 1, 18.0), (2, 3, 14.0), (2, 4, 12.0), (2, 5, 16.0),
-- From Sitabuldi
(3, 1, 7.5), (3, 2, 14.0), (3, 4, 3.0), (3, 5, 6.0),
-- From Dharampeth
(4, 1, 9.0), (4, 2, 12.0), (4, 3, 3.0), (4, 5, 7.5),
-- From Manewada
(5, 1, 4.0), (5, 2, 16.0), (5, 3, 6.0), (5, 4, 7.5);

-- ------------------------------------------------------------------------
UPDATE Drivers SET availability_status = 'Available' WHERE driver_id > 0;