import requests
import json

from bs4 import BeautifulSoup
from tqdm import tqdm

BASE_URL = 'https://fgc.cat'
LINES_URL = 'https://www.fgc.cat/es/red-fgc/l-'
ZONES = ['barcelona-valles', 'llobregat-anoia']

class LineStationUtils: 

    def __init__(self):
        self.lines_stations = {}
        self.fetch_station_lines()

    def add_station(self, lines_tot, names):
        for station, lines in zip(names, lines_tot):
            for line in lines:
                if line in self.lines_stations:
                    if station not in self.lines_stations[line]:
                        self.lines_stations[line].append(station)
                else:
                    self.lines_stations[line] = [station]

    def fetch_station_lines(self):

        for zone in ZONES:
            #obtenemos las linas de cada zona
            response = requests.get(LINES_URL+zone)
            soup = BeautifulSoup(response.content, 'html.parser')

            #iteramos sobre las linias para obtener cada parada
            for line in tqdm(soup.select('a.w-text-h'), desc=f'Fetching lines from {zone}'):

                link = line.get('href')
                response_line = requests.get(BASE_URL+link)
                soup_2 = BeautifulSoup(response_line.content, 'html.parser')
                
                names = []
                for name in soup_2.select('a.w-text-h span.w-text-value'):
                    name.text.replace('Av. T', 'Avinguda')
                    if name.text == "Plaça Catalunya":
                        names.append("Catalunya")
                    elif name.text != "Calcular":
                        names.append(name.text)

                if zone == 'barcelona-valles':
                    names = names[:-4]
                else:
                    names = names[:-8]
                
                #iteramos sobre todas las paradas de las estaciones
                lines_tot = []
                param_serch = 'barcelona_valles' if zone == 'barcelona-valles' else 'llobregar_anoia'

                for set_stations in soup_2.select(f'div.{param_serch}_linie'):

                    lines_aux = []
                    for station in set_stations.select('div.w-image img'):
                        if 'nord' in station.get('alt') or 'sud' in station.get('alt'):
                            lines_aux.append(station.get('alt').replace(' logo', ''))
                        else:
                            for part in station.get('alt').split(' '):
                                if len(part) <= 3:
                                    lines_aux.append(part)
                            
                    lines_tot += [lines_aux]

                self.add_station(lines_tot, names)
                

                
