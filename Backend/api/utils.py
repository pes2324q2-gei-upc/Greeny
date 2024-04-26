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

    transport_dist = total_distance / len(transports)
    co2_consumed = 0.0
    for transport in transports:
        if transport == 'Walking' or transport == 'Bike':
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

    if len(transports) != 0:
        total_transports = len(transports)
        transport_modes = ['Walking', 'Bus', 'Train, Metro, Tram, FGC', 'Bike', 'Car', 'Motorcycle',
                           'Electric Car']

        percentage = 100 / total_transports / 100
        km_mode = percentage * total_distance

        transport_percentages = {}
        for mode in transport_modes:
            if mode in transports:
                transport_percentages[mode] = km_mode
            else:
                transport_percentages[mode] = 0.0

        field_mapping = {
            'Walking': 'km_Walked',
            'Bus': 'km_Bus',
            'Train, Metro, Tram, FGC': 'km_PublicTransport',
            'Bike': 'km_Biked',
            'Car': 'km_Car',
            'Motorcycle': 'km_Motorcycle',
            'Electric Car': 'km_ElectricCar'
        }

        for key, value in transport_percentages.items():
            update_fields[field_mapping[key]] = value

        update_fields['km_Totals'] = total_distance

    return update_fields
