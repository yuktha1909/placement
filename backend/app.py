import time
import datetime
from datetime import timedelta
import random
import bcrypt
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_cors import cross_origin
from flask_jwt_extended import (
    JWTManager,
    create_access_token,
    jwt_required,
    get_jwt_identity,
    get_jwt
)
from flask_mysqldb import MySQL
from flask_mail import Mail, Message

app = Flask(__name__)
CORS(app)

# --- JWT Configuration ---
app.config['JWT_SECRET_KEY'] = 'your-secret-key'
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = False
jwt = JWTManager(app)

# --- MySQL Configuration ---
app.config['MYSQL_HOST']     = 'localhost'
app.config['MYSQL_USER']     = 'root'
app.config['MYSQL_PASSWORD'] = 'abcd1234@'
app.config['MYSQL_DB']       = 'auth_db'
mysql = MySQL(app)

# --- Mail Configuration ---
app.config['MAIL_SERVER']   = 'smtp.gmail.com'
app.config['MAIL_PORT']     = 465
app.config['MAIL_USE_SSL']  = True
app.config['MAIL_USERNAME'] = 'lakshanya726@gmail.com'
app.config['MAIL_PASSWORD'] = 'fhiw bnet uiol jtiw'
mail = Mail(app)


# --- User Registration ---
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    email, password = data.get('email'), data.get('password')
    role = data.get('role', 'user')

    cursor = mysql.connection.cursor()
    cursor.execute('SELECT 1 FROM users WHERE email=%s', (email,))
    if cursor.fetchone():
        cursor.close()
        return jsonify(error='Email already exists'), 409

    hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
    cursor.execute(
        'INSERT INTO users (email,password,role) VALUES (%s,%s,%s)',
        (email, hashed, role)
    )
    mysql.connection.commit()
    cursor.close()
    return jsonify(message='User registered successfully'), 201


# --- User Login ---
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email, password = data.get('email'), data.get('password')

    cursor = mysql.connection.cursor()
    cursor.execute(
        'SELECT id,email,password,role FROM users WHERE email=%s',
        (email,)
    )
    row = cursor.fetchone()
    cursor.close()

    if not row or not bcrypt.checkpw(password.encode(), row[2].encode()):
        return jsonify(error='Invalid email or password'), 401

    user_id, user_email, _, user_role = row

    token = create_access_token(
        identity=str(user_id),  
        additional_claims={"email": user_email, "role": user_role},
        expires_delta=False 
    )
    return jsonify(token=token, role=user_role), 200

# --- Send OTP for Password Reset ---
@app.route('/forgot-password', methods=['POST'])
def forgot_password():
    data = request.get_json()
    email = data.get('email')

    cursor = mysql.connection.cursor()
    cursor.execute('SELECT 1 FROM users WHERE email=%s', (email,))
    if not cursor.fetchone():
        cursor.close()
        return jsonify(error='No account found with that email'), 404

    otp = random.randint(100000, 999999)
    expiry = int(time.time()) + 15*60  # 15 minutes

    # remove old OTPs, then store new one
    cursor.execute('DELETE FROM password_resets WHERE email=%s', (email,))
    cursor.execute(
        'INSERT INTO password_resets (email,otp,expiry_time) VALUES (%s,%s,%s)',
        (email, otp, expiry)
    )
    mysql.connection.commit()
    cursor.close()

    try:
        msg = Message('Your Password Reset OTP',
                      sender=app.config['MAIL_USERNAME'],
                      recipients=[email])
        msg.body = f'Your OTP is {otp}. It expires at {datetime.datetime.fromtimestamp(expiry)}.'
        mail.send(msg)
    except Exception as e:
        return jsonify(error='Failed to send email', details=str(e)), 500

    return jsonify(message='OTP sent to your email'), 200


# --- Verify OTP and Issue Token ---
@app.route('/verify-otp', methods=['POST'])
def verify_otp():
    data  = request.get_json()
    email = data.get('email')
    otp   = data.get('otp')

    if not email or not otp:
        return jsonify(error='Email and OTP required'), 400

    cursor = mysql.connection.cursor()
    cursor.execute(
        'SELECT otp,expiry_time FROM password_resets '
        'WHERE email=%s ORDER BY expiry_time DESC LIMIT 1',
        (email,)
    )
    row = cursor.fetchone()
    if not row:
        cursor.close()
        return jsonify(error='No OTP request found'), 404

    stored_otp, expiry = row
    now = time.time()

    # debug logs (remove in prod)
    print('Stored OTP:', stored_otp)
    print('Expiry ts:', expiry, 'now ts:', now)

    if str(stored_otp) != str(otp):
        cursor.close()
        return jsonify(error='Invalid OTP'), 400
    if now > expiry:
        cursor.close()
        return jsonify(error='OTP expired'), 400

    # OK—delete used OTP and issue a JWT
    cursor.execute(
        'DELETE FROM password_resets WHERE email=%s AND otp=%s',
        (email, stored_otp)
    )
    mysql.connection.commit()
    cursor.close()

    token = create_access_token(identity={'email': email}, expires_delta=False)
    return jsonify(message='OTP verified', token=token), 200


# --- Reset Password ---
@app.route('/reset-password', methods=['POST'])
@jwt_required()
def reset_password():
    current_user = get_jwt_identity()
    print(f"Current user: {current_user}") 
    data = request.get_json()
    print(f"Request JSON: {data}")  

    password = data.get('password')
    if not password:
        return jsonify(error='Password is required'), 400

    try:
        cursor = mysql.connection.cursor()
        cursor.execute(
            'UPDATE users SET password=%s WHERE email=%s',
            (generate_password_hash(password), current_user['email'])
        )
        mysql.connection.commit()
        cursor.close()
        return jsonify(message='Password successfully reset'), 200
    except Exception as e:
        return jsonify(error=str(e)), 500
    
@app.route('/admin/dashboard', methods=['GET'])
@jwt_required()
def get_dashboard_data():
    cursor = mysql.connection.cursor()

    # Total students
    cursor.execute("SELECT COUNT(*) FROM students")
    total_students = cursor.fetchone()[0]

    # Latest placement status per student using a subquery
    cursor.execute("""
        SELECT COUNT(*) FROM (
            SELECT sh.student_id, sh.status
            FROM student_status_history sh
            INNER JOIN (
                SELECT student_id, MAX(changed_at) as latest
                FROM student_status_history
                GROUP BY student_id
            ) latest_status ON sh.student_id = latest_status.student_id AND sh.changed_at = latest_status.latest
            WHERE sh.status = 'Placed'
        ) AS placed
    """)
    placed_students = cursor.fetchone()[0]

    # Placement percentage
    placement_percentage = (placed_students / total_students * 100) if total_students > 0 else 0

    # Ongoing drives: placements with deadline in the future
    cursor.execute("SELECT COUNT(*) FROM placements WHERE deadline >= CURDATE()")
    ongoing_drives = cursor.fetchone()[0]

    # Total companies (distinct)
    cursor.execute("SELECT COUNT(DISTINCT company) FROM placements")
    total_companies = cursor.fetchone()[0]

    cursor.close()

    return jsonify({
        "totalStudents": total_students,
        "placedStudents": placed_students,
        "placementPercentage": round(placement_percentage, 2),
        "ongoingDrives": ongoing_drives,
        "totalCompanies": total_companies
    }), 200


# --- Fetch All Placements ---
@app.route('/placements', methods=['GET'])
def fetch_all_placements():
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT id,title,date,company,location,`package`,eligibility,deadline,description
        FROM placements
    ''')
    rows = cursor.fetchall()
    cols = [d[0] for d in cursor.description]
    cursor.close()

    result = []
    for r in rows:
        rec = dict(zip(cols, r))
        # no nulls
        for k,v in rec.items():
            if v is None: rec[k] = ''
        result.append(rec)

    return jsonify(placements=result), 200


# --- Add a Placement (admin only) ---
@app.route('/placements', methods=['POST'])
@jwt_required()
def add_placement():
    claims = get_jwt()
    if claims.get('role') != 'admin':
        return jsonify(error='Admins only'), 403

    data = request.get_json()
    fields = ['title','date','company','location','package','eligibility','deadline','description']
    if not all(data.get(f) for f in fields[:-1]):  # description may be empty
        return jsonify(error='Missing required fields'), 400
    
    vals = tuple(data.get(f) for f in fields)
    cursor = mysql.connection.cursor()
    cursor.execute(f'''
        INSERT INTO placements ({','.join(fields)})
        VALUES ({','.join(['%s']*len(fields))})
    ''', vals)
    mysql.connection.commit()
    cursor.close()

    return jsonify(message='Placement added'), 201

# --- Update a Placement (admin only) ---
@app.route('/placements/<int:id>', methods=['PUT'])
@jwt_required()
def update_placement(id):
    claims = get_jwt()
    if claims.get('role') != 'admin':
        return jsonify(error='Admins only'), 403

    # Get the data from the request
    data = request.get_json()
    fields = ['title', 'date', 'company', 'location', 'package', 'eligibility', 'deadline', 'description']

    # Check if all required fields are present (except description which can be empty)
    missing_fields = [field for field in fields if not data.get(field) and field != 'description']
    if missing_fields:
        return jsonify(error=f'Missing fields: {", ".join(missing_fields)}'), 400

    # Prepare the SQL query for updating
    set_clause = ', '.join(f"{f}=%s" for f in fields)
    vals = tuple(data.get(f) for f in fields) + (id,)

    # Execute the update query
    cursor = mysql.connection.cursor()
    cursor.execute(f"UPDATE placements SET {set_clause} WHERE id=%s", vals)
    mysql.connection.commit()
    cursor.close()

    return jsonify(message='Placement updated'), 200

# --- Delete a Placement (admin only) ---
@app.route('/placements/<int:id>', methods=['DELETE'])
@jwt_required()
def delete_placement(id):
    claims = get_jwt()
    if claims.get('role')!='admin':
        return jsonify(error='Admins only'), 403

    cursor = mysql.connection.cursor()
    cursor.execute('DELETE FROM placements WHERE id=%s', (id,))
    mysql.connection.commit()
    cursor.close()
    return jsonify(message='Placement deleted'), 200

#----Get a student details----
@app.route('/students', methods=['GET'])
@jwt_required()
def get_students():
    claims = get_jwt()
    if claims.get('role') != 'admin':
        return jsonify(error='Admins only'), 403

    cursor = mysql.connection.cursor()
    cursor.execute('SELECT id, name, email, phone, address, course, year, resume_link, status FROM students')
    rows = cursor.fetchall()
    cursor.close()

    # Convert the rows into dictionaries
    students = []
    for row in rows:
        students.append({
            'id': row[0],
            'name': row[1],
            'email': row[2],
            'phone': row[3],
            'address': row[4],
            'course': row[5],
            'year': row[6],
            'resume_link': row[7],
            'status': row[8]
        })

    return jsonify(students=students), 200

#----Add student----
@app.route('/students', methods=['POST'])
@jwt_required()
def add_student():
    claims = get_jwt()
    if claims.get('role') != 'admin':
        return jsonify(error='Admins only'), 403

    data = request.get_json()
    name = data.get('name')
    email = data.get('email')
    phone = data.get('phone')
    address = data.get('address')
    course = data.get('course')
    year = data.get('year')
    resume_link = data.get('resume_link')

    if not name or not email:
        return jsonify(error='Name and email are required'), 400

    cursor = mysql.connection.cursor()
    # Check if email already exists (optional, but good practice)
    cursor.execute('SELECT id FROM students WHERE email = %s', (email,))
    if cursor.fetchone():
        cursor.close()
        return jsonify(error='Student with this email already exists'), 409

    cursor.execute(
        '''INSERT INTO students (name, email, phone, address, course, year, resume_link)
           VALUES (%s, %s, %s, %s, %s, %s, %s)''',
        (name, email, phone, address, course, year, resume_link)
    )
    mysql.connection.commit()
    cursor.close()

    return jsonify(message='Student added successfully'), 201

# --- Update Student Information (admin only) ---
@app.route('/students/<int:id>', methods=['PUT'])
@jwt_required()
def update_student(id):
    claims = get_jwt()
    if claims.get('role') != 'admin':
        return jsonify(error='Admins only'), 403

    data = request.get_json()
    name = data.get('name')
    email = data.get('email')
    phone = data.get('phone')
    address = data.get('address')
    course = data.get('course')
    year = data.get('year')
    resume_link = data.get('resume_link')

    if not name or not email:
        return jsonify(error='Name and email are required'), 400

    cursor = mysql.connection.cursor()
    cursor.execute('SELECT 1 FROM students WHERE id=%s', (id,))
    if not cursor.fetchone():
        cursor.close()
        return jsonify(error='Student not found'), 404

    cursor.execute(
        '''UPDATE students
           SET name=%s, email=%s, phone=%s, address=%s, course=%s, year=%s, resume_link=%s
           WHERE id=%s''',
        (name, email, phone, address, course, year, resume_link, id)
    )
    mysql.connection.commit()
    cursor.close()

    return jsonify(message='Student updated successfully'), 200

@app.route('/students/<int:id>', methods=['DELETE'])
@jwt_required()
def delete_student(id):
    claims = get_jwt()
    if claims.get('role') != 'admin':
        return jsonify(error='Admins only'), 403

    cursor = mysql.connection.cursor()

    # 1) Check student exists
    cursor.execute('SELECT 1 FROM students WHERE id=%s', (id,))
    if not cursor.fetchone():
        cursor.close()
        return jsonify(error='Student not found'), 404

    try:
        # 2) Delete any status history
        cursor.execute(
            'DELETE FROM student_status_history WHERE student_id = %s',
            (id,)
        )

        # 3) Now delete the student
        cursor.execute('DELETE FROM students WHERE id=%s', (id,))
        mysql.connection.commit()

    except Exception as e:
        mysql.connection.rollback()
        cursor.close()
        return jsonify(error='Deletion failed', details=str(e)), 500

    cursor.close()
    return jsonify(message='Student deleted successfully'), 200


# --- Update Student Status (admin only) ---
@app.route('/students/<int:id>/status', methods=['PUT'])
@jwt_required()
def update_student_status(id):
    claims = get_jwt()
    if claims.get('role') != 'admin':
        return jsonify(error='Admins only'), 403

    data = request.get_json()
    status = data.get('status')
    
    if not status:
        return jsonify(error='Status is required'), 400

    # Check if the student exists
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT 1 FROM students WHERE id=%s', (id,))
    if not cursor.fetchone():
        cursor.close()
        return jsonify(error='Student not found'), 404

    # Update the status of the student
    cursor.execute('UPDATE students SET status=%s WHERE id=%s', (status, id))
    mysql.connection.commit()

    # Record the status change in student_status_history table
    cursor.execute(
        'INSERT INTO student_status_history (student_id, status) VALUES (%s, %s)',
        (id, status)
    )
    mysql.connection.commit()
    cursor.close()

    return jsonify(message='Student status updated and history recorded successfully'), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
