import json
import os

import firebase_admin
from firebase_admin import credentials, firestore
from flask import Flask, jsonify, request, send_file

app = Flask(__name__)

# Construct the absolute path to the service account key JSON file
service_account_key_path = os.path.join(os.path.dirname(__file__), 'confidential', 'guidely-e789f-firebase-adminsdk-o2atr-7cbeb1f895.json')

# Initialize Firebase Admin SDK
cred = credentials.Certificate(service_account_key_path)
firebase_admin.initialize_app(cred)

# Get a Firestore client
db = firestore.client()

DATA_FILE = 'data/requests.json'

def read_requests():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, 'r') as file:
            return json.load(file)
    return []

def write_requests(requests_data):
    with open(DATA_FILE, 'w') as file:
        json.dump(requests_data, file, indent=4)

@app.route('/submit-user-data', methods=['POST'])
def submit_user_data():
    data = request.json
    uid = data.get('uid')
    username = data.get('username')
    email = data.get('email')
    auth_state = data.get('authState')
    registration_data = data.get('registrationData')
    
    description = registration_data.get('description')
    uploaded_url = registration_data.get('uploadedUrl')

    new_request = {
        "user_id": uid,
        "name": username,
        "email": email,
        "message": description
    }

    requests_data = read_requests()
    requests_data.append(new_request)
    write_requests(requests_data)

    return jsonify({'message': 'User data received successfully'})

@app.route('/reject-request', methods=['POST'])
def reject_request():
    """Endpoint to reject a request."""
    data = request.json
    request_index = data.get('index')

    # Convert request_index to an integer
    try:
        request_index = int(request_index)
    except ValueError:
        return jsonify({'error': 'Invalid request index format'}), 400

    # Read requests data from file
    requests_data = read_requests()

    if 0 <= request_index < len(requests_data):
        # Remove the request at the specified index
        rejected_request = requests_data.pop(request_index)

        # Write updated requests data back to the file
        write_requests(requests_data)

        # Notify the mobile application that the request was rejected
        notification_message = f"Request from {rejected_request['name']} was rejected"
        
        # Get the user ID from the rejected request
        user_id = rejected_request.get('user_id')

        if user_id:
            # Update AuthState in Firestore
            try:
                user_ref = db.collection('users').document(user_id)
                user_ref.update({'authState': 'unauthenticated'})
            except Exception as e:
                return jsonify({'error': f'Failed to update Firestore: {e}'}), 500

        return jsonify({'message': 'Request rejected successfully', 'notification': notification_message})
    else:
        return jsonify({'error': 'Invalid request index'}), 400
    
@app.route('/requests')
def get_requests():
    page = int(request.args.get('page', 1))
    pageSize = int(request.args.get('pageSize', 10))
    search_query = request.args.get('search', '').lower()

    requests_data = read_requests()
    filtered_requests = [req for req in requests_data if search_query in req['name'].lower()]

    start_index = (page - 1) * pageSize
    end_index = min(start_index + pageSize, len(filtered_requests))
    paginated_data = filtered_requests[start_index:end_index]

    return jsonify({
        "requests": paginated_data,
        "totalItems": len(filtered_requests)
    })

@app.route('/')
def serve_index():
    return send_file('index.html')

@app.route('/static/<path:path>')
def send_static(path):
    return send_file(os.path.join('static', path))

if __name__ == '__main__':
    app.run(debug=True)
