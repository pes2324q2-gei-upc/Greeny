# Greeny

[![Docker Image CI](https://github.com/pes2324q2-gei-upc/Greeny/actions/workflows/docker-image.yml/badge.svg?branch=main)](https://github.com/pes2324q2-gei-upc/Greeny/actions/workflows/docker-image.yml) [![Pylint](https://github.com/pes2324q2-gei-upc/Greeny/actions/workflows/pylint.yml/badge.svg)](https://github.com/pes2324q2-gei-upc/Greeny/actions/workflows/pylint.yml) [![Django CI](https://github.com/pes2324q2-gei-upc/Greeny/actions/workflows/django.yml/badge.svg)](https://github.com/pes2324q2-gei-upc/Greeny/actions/workflows/django.yml) [![Flutter](https://github.com/pes2324q2-gei-upc/Greeny/actions/workflows/flutter.yml/badge.svg)](https://github.com/pes2324q2-gei-upc/Greeny/actions/workflows/flutter.yml)

Aplicació de mobilitat sostenible

## Integrants
- Amorín Díaz, Miquel
- Costabella Moreno, Agustí
- López Buira, Iván
- López Ruiz, Alba 
- Mostazo Gonzalez, Marc
- Tajahuerce Brulles, Arnau
- Vega Centeno, Javier

## Conception of the project

<p align="center">
  <img src="https://github.com/pes2324q2-gei-upc/Greeny/blob/develop/App/greeny/assets/icons/appicon.png?raw=true" alt="Greeny Logo" width="200"/>
</p>

El nostre projecte consisteix en una aplicació mòbil que té com a idea principal un concepte innovador: un joc interactiu orientat en la sostenibilitat urbana, centrat en l'objectiu de descontaminar una ciutat. Mitjançant una aplicació mòbil, els usuaris tindran l'oportunitat de participar activament en aquest desafiament ambiental. A través de mecàniques de joc inspiradores i educatives, els jugadors seran responsables de prendre decisions sobre els seus desplaçaments diaris i, al mateix temps, contribuir a la reducció de la contaminació i al creixement de la sostenibilitat urbana.

La proposta del nostre projecte ofereix una experiència lúdica única, on els usuaris no només reben informació sobre punts de recàrrega elèctrica, estacions de Bicing i parades de transport públic, sinó que també es converteixen en protagonistes de la transformació d'una ciutat contaminada en un entorn més saludable i sostenible. Amb una combinació de gamificació, geolocalització i interacció social, aspirem a crear una plataforma que no només entretingui, sinó que també eduqui i motivi els usuaris a adoptar hàbits de vida més respectuosos amb el medi ambient. Així, el nostre projecte no només és una aplicació mòbil, sinó una iniciativa per a la conscienciació i la millora de la sostenibilitat urbana.

## Instruccions per executar el projecte

### Backend
#### Posar en marxa:

1. Baixarse el repo

2. Instalarse docker

3. Situarse a la carpeta backend

#### Run dels dockers corresponents

```sh
docker-compose build
docker compose up
```

#### Per fer migracions

```sh
docker compose run backend python manage.py migrate
```


#### Per crear migracions

```sh
docker compose run backend python manage.py makemigrations
```

> **Note:** Assegurat de posar al `./Backend/.env` les variables d'entorn necessaries:
>```
>POSTGRES_NAME=
>POSTGRES_USER=
>POSTGRES_PASSWORD=
>POSTGRES_DB=
>DB_HOST=
>API_KEY=
>API_KEY_ID=
>APP_TOKEN=
>APP_ID=
>API_TOKEN_AJT=
>```

### Frontend
> **Macos:** Descarregar `cocoapod`

#### Preparació
1. Instalar extensió flutter a vscode (potser també instalar flutter)
2. Instalar emulador mobil (Xcode/Android Studio)

#### Run app
1. A baix a la dreta de vscode seleccionar un dispositiu per executar el front end
2. Seleccionar l'arxiu `./App/greeny/lib/main.dart`
3. Donar-li a `Start debugging`.

#### Instalar la app
```sh
flutter run --release
```

> **Note:** Assegurat de posar al `./App/greeny/.env` el `BACKEND_URL=` necessari:
>
> `BACKEND_URL = 'url o IP del backend'`
>
> Per defecte: `BACKEND_URL = 'nattech.fib.upc.edu:40351'`

## Folder Sctructure

```
.
├── App
│   └── greeny
│       ├── analysis_options.yaml
│       ├── android
│       ├── assets          #Directori d'assets de l'aplicació
│       ├── build
│       ├── greeny.iml
│       ├── ios
│       ├── lib             #Directori que conté el codi principal de l'aplicació
│       ├── linux
│       ├── macos
│       ├── pubspec.lock
│       ├── pubspec.yaml    #Arxiu que conte la llista de dependencies i altra informació 
│       │                   rellevant per el gestor de paquets Dart (pub)
│       ├── test            #Directori que conté els tests del Frontend
│       ├── web
│       └── windows
├── Backend
│   ├── Dockerfile          #Arxiu amb instruccions per construir la imatge del Backend
│   ├── api                 #Directori amb el codi de la API del Backend
│   ├── docker-compose.yml  #Arxiu amb la configuració dels contenidors
│   ├── greeny
│   ├── manage.py
│   └── requirements.txt    #Dependencies del Backend
└── README.md
```
