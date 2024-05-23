import requests


class ICQAAirmonAdapter:
    BASE_URL = 'http://51.21.149.211' # Reemplaza esto con la URL base de la API ICQA

    @staticmethod
    def get_icqa(coords):
        url = f"{ICQAAirmonAdapter.BASE_URL}/api/icqa/"  # Reemplaza esto con el endpoint correcto
        data = {'points': coords}

        response = requests.post(url, json=data)

        if response.status_code == 200:
            return response.json()
        else:
            response.raise_for_status()
