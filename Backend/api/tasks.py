import requests
from .models import YourModel  # Import your Django model
from views import BASE_URL_AJT, ID_ESTACIONS_TRANSPORT, headers_AJT

def check_api_updates():
    # Make API request to get updates
    # Checks for updates in data from APIs f.e if a new station is created.
    response = requests.get(url=(BASE_URL_AJT + ID_ESTACIONS_TRANSPORT + "&limit=700"));
    
    if response.status_code == 200:
        data = response.json()
        stations = data.get("result").get("records")

        # Hacer logica para modificar filas en la db
    else:
        print("Failed to fetch updates from API:", response.status_code)