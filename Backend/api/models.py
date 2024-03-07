from django.db import models

class User(models.Model):
    nom = models.CharField(blank=False, null=False, verbose_name='Nom')
    username = models.CharField(primary_key=True, blank=False, null=False, verbose_name='Username')
    password = models.CharField(blank=False, null=False, verbose_name='Password')
    email = models.EmailField(blank=False, null=False, verbose_name='Email')

    class Meta:
        verbose_name_plural = 'Users'