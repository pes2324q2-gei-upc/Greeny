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

1. `docker compose up`

### Per fer migracions

`docker compose run backend python manage.py migrate`

### Per crear migracions

`docker compose run backend python manage.py makemigrations`

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


