from django.apps import apps
from django.contrib import admin

# Get all model classes
models = apps.get_models()

# Register each model with the admin site
for model in models:
    try:
        admin.site.register(model)
    except admin.sites.AlreadyRegistered:
        pass