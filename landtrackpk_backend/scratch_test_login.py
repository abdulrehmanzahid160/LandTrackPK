import requests

url = "http://127.0.0.1:5000/api/login"
payload = {
    "cnic": "3520198765432",
    "password": "admin123",
    "role": "Citizen"
}

try:
    response = requests.post(url, json=payload)
    print("Status Code:", response.status_code)
    print("Response JSON:", response.json())
except Exception as e:
    print("Error:", e)
