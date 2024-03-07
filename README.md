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
## Posar en marxa:

1. Baixarse el repo

2. Instalarse docker

3. Situarse a la carpeta backend

## Run dels dockers corresponents

1. `docker compose up`

## Per fer migracions

1. `docker compose run backend python manage.py migrate`

2. Per crear migracions

3. `docker compose run backend python manage.py makemigrations`
