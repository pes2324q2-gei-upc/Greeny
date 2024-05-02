# Greeny

Aplicació de mobilitat sostenible

## Integrants
- Amorín Díaz, Miquel
- Costabella Moreno, Agustí
- López Buira, Iván
- López Ruiz, Alba 
- Mostazo Gonzalez, Marc
- Tajahuerce Brulles, Arnau
- Vega Centeno, Javier

---

## Backend
### Posar en marxa:

1. Baixarse el repo

2. Instalarse docker

3. Situarse a la carpeta backend

### Run dels dockers corresponents

```sh
docker-compose build
docker compose up
```

### Per fer migracions

```sh
docker compose run backend python manage.py migrate
```


### Per crear migracions

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

---
## Frontend
> **Macos:** Descarregar `cocoapod`

### Preparació
1. Instalar extensió flutter a vscode (potser també instalar flutter)
2. Instalar emulador mobil (Xcode/Android Studio)

### Run app
1. A baix a la dreta de vscode seleccionar un dispositiu per executar el front end
2. Seleccionar l'arxiu `./App/greeny/lib/main.dart`
3. Donar-li a `Start debugging`.

### Instalar la app
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
│       ├── README.md
│       ├── analysis_options.yaml
│       ├── android
│       │   ├── app
│       │   ├── build.gradle
│       │   ├── gradle
│       │   ├── gradle.properties
│       │   ├── local.properties
│       │   └── settings.gradle
│       ├── assets
│       │   ├── i18n
│       │   ├── icons
│       │   ├── images
│       │   ├── locations
│       │   ├── neighborhoods
│       │   └── transports
│       ├── build
│       │   ├── 26c1224f28ba1925f2521c2679048535.cache.dill.track.dill
│       │   ├── 89206ed3eb89d27330a6e9697464aad2
│       │   └── ios
│       ├── greeny.iml
│       ├── ios
│       │   ├── Flutter
│       │   ├── Podfile
│       │   ├── Podfile.lock
│       │   ├── Pods
│       │   ├── Runner
│       │   ├── Runner.xcodeproj
│       │   ├── Runner.xcworkspace
│       │   └── RunnerTests
│       ├── lib
│       │   ├── API
│       │   ├── City
│       │   ├── Friends
│       │   ├── Map
│       │   ├── Profile
│       │   ├── Registration
│       │   ├── Statistics
│       │   ├── app_state.dart
│       │   ├── loading_screen.dart
│       │   ├── main.dart
│       │   ├── main_page.dart
│       │   └── translate.dart
│       ├── linux
│       │   ├── CMakeLists.txt
│       │   ├── flutter
│       │   ├── main.cc
│       │   ├── my_application.cc
│       │   └── my_application.h
│       ├── macos
│       │   ├── Flutter
│       │   ├── Podfile
│       │   ├── Podfile.lock
│       │   ├── Pods
│       │   ├── Runner
│       │   ├── Runner.xcodeproj
│       │   ├── Runner.xcworkspace
│       │   └── RunnerTests
│       ├── pubspec.lock
│       ├── pubspec.yaml
│       ├── test
│       │   ├── city_view_test.dart
│       │   ├── model_viewer_test.dart
│       │   └── track_km_test.dart
│       ├── web
│       │   ├── favicon.png
│       │   ├── icons
│       │   ├── index.html
│       │   └── manifest.json
│       └── windows
│           ├── CMakeLists.txt
│           ├── flutter
│           └── runner
├── Backend
│   ├── Dockerfile
│   ├── api
│   │   ├── __init__.py
│   │   ├── __pycache__
│   │   │   ├── __init__.cpython-311.pyc
│   │   │   └── apps.cpython-311.pyc
│   │   ├── admin.py
│   │   ├── apps.py
│   │   ├── city_views.py
│   │   ├── fixtures
│   │   │   └── mock_api.json
│   │   ├── friend_view.py
│   │   ├── management
│   │   │   └── commands
│   │   ├── migrations
│   │   │   ├── 0001_initial.py
│   │   │   └── __init__.py
│   │   ├── models.py
│   │   ├── ping_view.py
│   │   ├── review_views.py
│   │   ├── routes_views.py
│   │   ├── serializers.py
│   │   ├── statistics_views.py
│   │   ├── tests.py
│   │   ├── transports_views.py
│   │   ├── urls.py
│   │   ├── user_views.py
│   │   └── utils.py
│   ├── docker-compose.yml
│   ├── greeny
│   │   ├── __init__.py
│   │   ├── asgi.py
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   ├── manage.py
│   └── requirements.txt
└── README.md
```
