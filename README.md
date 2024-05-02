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
│       ├── assets
│       ├── build
│       ├── greeny.iml
│       ├── ios
│       ├── lib
│       ├── linux
│       ├── macos
│       ├── pubspec.lock
│       ├── pubspec.yaml
│       ├── test
│       ├── web
│       └── windows
├── Backend
│   ├── Dockerfile
│   ├── api
│   ├── docker-compose.yml
│   ├── greeny
│   ├── manage.py
│   └── requirements.txt
└── README.md
```
