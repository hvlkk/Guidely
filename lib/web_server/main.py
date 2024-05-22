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

    print('new_request: ', new_request)

    requests_data = read_requests()
    requests_data.append(new_request)
    write_requests(requests_data)

    return jsonify({'message': 'User data received successfully'})

@app.route('/reject-request', methods=['POST'])
def reject_request():
    """Endpoint to reject a request."""
    data = request.json
    user_id = data.get('userId') # Retrieve user_id instead of index
    print('user_id: ', user_id)

    if user_id:
        # Read requests data from file
        requests_data = read_requests()

        # Find the request by user_id
        rejected_request = None
        for request_data in requests_data:
            if request_data.get('user_id') == user_id:
                rejected_request = request_data
                break
        
        print('rejected_request: ', rejected_request)
        if rejected_request:
            # Remove the rejected request from the list
            requests_data.remove(rejected_request)

            # Write updated requests data back to the file
            write_requests(requests_data)

            # Notify the mobile application that the request was rejected
            notification_message = f"Request from {rejected_request['name']} was rejected"

            # Update AuthState in Firestore
            try:
                user_ref = db.collection('users').document(user_id)
                user_ref.update({'authState': 0})
            except Exception as e:
                return jsonify({'error': f'Failed to update Firestore: {e}'}), 500

            return jsonify({'message': 'Request rejected successfully', 'notification': notification_message})
        else:
            return jsonify({'error': 'Request not found'}), 404
    else:
        return jsonify({'error': 'Missing user ID'}), 400

@app.route('/accept-request', methods=['POST'])
def aveppro_request():
    """Endpoint to accept a request."""
    data = request.json
    user_id = data.get('userId')  # Retrieve user_id from the request data
    print('user_id: ', user_id)

    if user_id:
        # Read requests data from file
        requests_data = read_requests()

        # Find the request by user_id
        approved_request = None
        for request_data in requests_data:
            if request_data.get('user_id') == user_id:
                approved_request = request_data
                break

        print('accepted_request: ', approved_request)
        if approved_request:
            # Remove the rejected request from the list
            requests_data.remove(approved_request)

            # Write updated requests data back to the file
            write_requests(requests_data)

            # For demonstration, let's print a success message.
            notification_message = f"Request from {approved_request['name']} was accepted"

            # Update AuthState in Firestore or perform any other necessary actions
            try:
                user_ref = db.collection('users').document(user_id)
                user_ref.update({'authState': 2})  # Update authState to indicate request accepted
            except Exception as e:
                return jsonify({'error': f'Failed to update Firestore: {e}'}), 500

            return jsonify({'message': 'Request accepted successfully', 'notification': notification_message})
        else:
            return jsonify({'error': 'Request not found'}), 404
    else:
        return jsonify({'error': 'Missing user ID'}), 400


    
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
