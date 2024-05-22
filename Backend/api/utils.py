from .models import Blacklist
from googletrans import Translator

def calculate_co2_consumed(transports, total_distance):
    # Calculate the CO2 consumed by the user
    # 0.0 kg CO2 per km for walking and biking
    # 0.08074 kg CO2 per km for Bus
    # 0.053 kg CO2 per km for Motorcycle
    # 0.143 kg CO2 per km for Car (Gasoline)
    # 0.070 kg CO2 per km for Electric Car
    # 0.05013 kg CO2 per km for Metro
    # 0.08012 kg CO2 per km for Tram
    # 0.03577 kg CO2 per km for FGC
    # 0.04688 kg CO2 per km for Train

    co2_consumed = 0.0
    for transport, percentage in transports.items():
        transport_dist = total_distance * (percentage / 100)
        if transport in ('Walking', 'Bike'):
            co2_consumed += 0.0
        elif transport == 'Metro':
            co2_consumed += 0.05013 * transport_dist
        elif transport == 'Tram':
            co2_consumed += 0.08012 * transport_dist
        elif transport == 'FGC':
            co2_consumed += 0.03577 * transport_dist
        elif transport == 'Train':
            co2_consumed += 0.04688 * transport_dist
        elif transport == 'Bus':
            co2_consumed += 0.08074 * transport_dist
        elif transport == 'Motorcycle':
            co2_consumed += 0.053 * transport_dist
        elif transport == 'Car':
            co2_consumed += 0.143 * transport_dist
        elif transport == 'Electric Car':
            co2_consumed += 0.070 * transport_dist
    return co2_consumed

def calculate_car_co2_consumed(total_distance):
    # Calculate the CO2 consumed by the user if they had used a car
    # 0.143 kg CO2 per km for Car (Gasoline)
    return 0.143 * total_distance

def calculate_statistics(transports, total_distance):
    update_fields = {
        'km_Walked': 0.0,
        'km_Bus': 0.0,
        'km_PublicTransport': 0.0,
        'km_Biked': 0.0,
        'km_Car': 0.0,
        'km_Motorcycle': 0.0,
        'km_ElectricCar': 0.0,
        'km_Totals': 0.0,
    }

    field_mapping = {
        'Walking': 'km_Walked',
        'Bus': 'km_Bus',
        'Train': 'km_PublicTransport',
        'Metro': 'km_PublicTransport',
        'Tram': 'km_PublicTransport',
        'FGC': 'km_PublicTransport',
        'Bike': 'km_Biked',
        'Car': 'km_Car',
        'Motorcycle': 'km_Motorcycle',
        'Electric Car': 'km_ElectricCar'
    }

    for transport, percentage in transports.items():
        km_mode = total_distance * (percentage / 100)
        update_fields[field_mapping[transport]] += km_mode

    update_fields['km_Totals'] = total_distance

    return update_fields

def calculate_points(co2_consumed, car_co2_consumed):
    # Calculate the points earned by the user
    alpha = 1 if co2_consumed == 0 else car_co2_consumed / co2_consumed
    co2_saved = max(0, car_co2_consumed - co2_consumed)
    total_points = co2_saved * alpha

    multiplier = 2

    return int(round(total_points * multiplier))

def check_for_ban(user):
    if user.reports == 3:
        invalidate_user(user)
        return True
    return False

def invalidate_user(user):
    #añadir a lista negra.
    user.is_active = False
    user.save()
    Blacklist.objects.create(email=user.email)

def translate(text, lang):
    translator = Translator()
    result = translator.translate(text, src=lang, dest='en').text
    return result