import requests

from bs4 import BeautifulSoup
from tqdm import tqdm

BASE_URL_FGC = 'https://fgc.cat'
LINES_URL_FGC = 'https://www.fgc.cat/es/red-fgc/l-'
ZONES = ['barcelona-valles', 'llobregat-anoia']

BASE_URL_RENFE = 'https://rodalies.gencat.cat'


class LineStationUtils:

    def __init__(self):
        self.lines_stations = {}
        self.fetch_station_lines_fgc()
        self.fetch_station_lines_renfe()

    def add_station(self, lines_tot, names):
        for station, lines in zip(names, lines_tot):
            for line in lines:
                if line in self.lines_stations:
                    if station not in self.lines_stations[line]:
                        self.lines_stations[line].append(station)
                else:
                    self.lines_stations[line] = [station]

    def process_line(self, line, zone):
        link = line.get('href')
        response_line = requests.get(BASE_URL_FGC + link, timeout=5)
        soup_2 = BeautifulSoup(response_line.content, 'html.parser')

        names = []
        for name in soup_2.select('a.w-text-h span.w-text-value'):
            name = name.text.replace('Av. T', 'Avinguda')
            if name == "Plaça Catalunya":
                names.append("Catalunya")
            elif name != "Calcular":
                names.append(name)

        if zone == 'barcelona-valles':
            names = names[:-4]
        else:
            names = names[:-8]

        lines_tot = []
        param_search = (
                'barcelona_valles'
                if zone == 'barcelona-valles'
                else 'llobregar_anoia'
            )

        for set_stations in soup_2.select(f'div.{param_search}_linie'):
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

    def fetch_station_lines_fgc(self):
        for zone in ZONES:
            response = requests.get(LINES_URL_FGC + zone, timeout=5)
            soup = BeautifulSoup(response.content, 'html.parser')

            for line in tqdm(soup.select('a.w-text-h'), desc=f'Fetching lines from {zone}'):
                self.process_line(line, zone)

    def process_renfe_line(self, line):
        line_link = line.select_one('a').get('href')

        line_response = requests.get(BASE_URL_RENFE + line_link, timeout=5)
        soup2 = BeautifulSoup(line_response.content, 'html.parser')

        names = []

        for name in soup2.select('div.timeline-title'):
            name = name.text.replace('Barcelona-', '')
            name = name.replace('-Meridiana', '')

            if 'Bellvitge' in name:
                names.append("Bellvitge")
            elif name == 'Sants':
                names.append('Sants Estació')
            elif name == 'EL CLOT':
                names.append('CLOT')
            else:
                names.append(name)

        serveis_divs = soup2.find_all('div', class_='serveis')

        all_alt_lists = []

        for serveis_div in serveis_divs:
            first_ul = serveis_div.find('ul')
            alt_list = []

            if first_ul:
                for li in first_ul.find_all('li'):
                    for img in li.find_all('img'):
                        alt = img.get('alt')
                        if alt:
                            alt_list.append(alt)
            if alt_list:
                all_alt_lists.append(alt_list)

        self.add_station(all_alt_lists, names)

    def fetch_station_lines_renfe(self):
        response = requests.get(BASE_URL_RENFE + '/es/linies_estacions_i_trens/', timeout=5)
        soup = BeautifulSoup(response.content, 'html.parser')

        for i, line in tqdm(enumerate(soup.select('.linia')), desc="Fetching RENFE lines"):
            if i > 5:
                break

            self.process_renfe_line(line)
