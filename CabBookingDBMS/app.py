from flask import Flask, render_template, request, redirect, url_for
import mysql.connector
import math

app = Flask(__name__)

def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",        
        password="root", # <-- PUT YOUR PASSWORD HERE
        database="cab_booking"
    )

# --- 1. USER BOOKING DASHBOARD ---
@app.route('/', methods=['GET', 'POST'])
def index():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'POST':
        user_name = request.form['name']
        pickup_id = int(request.form['pickup'])
        dropoff_id = int(request.form['dropoff'])

        if pickup_id == dropoff_id:
            return "Pickup and Drop-off cannot be the same!"

        # --- NEW LOGIC: Get distance directly from the Routes table ---
        route_query = "SELECT distance_km FROM Routes WHERE source_id = %s AND destination_id = %s"
        cursor.execute(route_query, (pickup_id, dropoff_id))
        route_result = cursor.fetchone()

        if route_result:
            distance = route_result['distance_km']
            fare = round(distance * 15, 2) # Calculating fare at Rs 15 per km
            
            # Insert Ride
            insert_query = "INSERT INTO Rides (user_name, pickup_loc_id, dropoff_loc_id, distance, fare) VALUES (%s, %s, %s, %s, %s)"
            cursor.execute(insert_query, (user_name, pickup_id, dropoff_id, distance, fare))
            conn.commit()
            ride_id = cursor.lastrowid
            
            cursor.close()
            conn.close()
            return redirect(url_for('ride_status', ride_id=ride_id))
        else:
            return "Sorry, we don't have route data for that combination yet!"

    # Fetch locations for the dropdown menu
    cursor.execute("SELECT * FROM Locations")
    locations = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('index.html', locations=locations)

# --- 2. USER LIVE STATUS PAGE ---
@app.route('/status/<int:ride_id>')
def ride_status(ride_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    # Use JOIN to get Driver details if assigned
    query = """
        SELECT r.*, d.name as driver_name, v.model, v.plate_number 
        FROM Rides r 
        LEFT JOIN Drivers d ON r.driver_id = d.driver_id
        LEFT JOIN Vehicles v ON d.driver_id = v.driver_id
        WHERE r.ride_id = %s
    """
    cursor.execute(query, (ride_id,))
    ride = cursor.fetchone()
    
    cursor.close()
    conn.close()
    return render_template('status.html', ride=ride)

# --- 3. DRIVER DASHBOARD ---
@app.route('/driver', methods=['GET', 'POST'])
def driver_dashboard():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    current_driver_id = request.args.get('driver_id', 1, type=int)

    if request.method == 'POST':
        ride_id = request.form['ride_id']
        action = request.form['action']

        if action == 'accept':
            cursor.execute("SELECT availability_status FROM Drivers WHERE driver_id = %s", (current_driver_id,))
            status = cursor.fetchone()
            if status and status['availability_status'] == 'Available':
                cursor.execute("UPDATE Rides SET status = 'Accepted', driver_id = %s WHERE ride_id = %s", (current_driver_id, ride_id))
                cursor.execute("UPDATE Drivers SET availability_status = 'Busy' WHERE driver_id = %s", (current_driver_id,))
                conn.commit()
                
        elif action == 'reject':
            cursor.execute("UPDATE Rides SET status = 'Rejected' WHERE ride_id = %s", (ride_id,))
            conn.commit()
            
        elif action == 'complete':
            # NEW LOGIC: Mark ride as completed and free up the driver
            cursor.execute("UPDATE Rides SET status = 'Completed' WHERE ride_id = %s", (ride_id,))
            cursor.execute("UPDATE Drivers SET availability_status = 'Available' WHERE driver_id = %s", (current_driver_id,))
            conn.commit()

    # Get pending rides for the table
    query_pending = """
        SELECT r.ride_id, r.user_name, r.fare, l1.name as pickup, l2.name as dropoff 
        FROM Rides r
        JOIN Locations l1 ON r.pickup_loc_id = l1.location_id
        JOIN Locations l2 ON r.dropoff_loc_id = l2.location_id
        WHERE r.status = 'Pending'
    """
    cursor.execute(query_pending)
    pending_rides = cursor.fetchall()

    # NEW LOGIC: Get the currently active ride for the selected driver
    query_active = """
        SELECT r.ride_id, r.user_name, r.fare, l1.name as pickup, l2.name as dropoff 
        FROM Rides r
        JOIN Locations l1 ON r.pickup_loc_id = l1.location_id
        JOIN Locations l2 ON r.dropoff_loc_id = l2.location_id
        WHERE r.status = 'Accepted' AND r.driver_id = %s
    """
    cursor.execute(query_active, (current_driver_id,))
    active_ride = cursor.fetchone()

    # Get all drivers for the dropdown
    cursor.execute("SELECT * FROM Drivers")
    all_drivers = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template('driver.html', rides=pending_rides, drivers=all_drivers, current_driver_id=current_driver_id, active_ride=active_ride)

if __name__ == '__main__':
    app.run(debug=True)