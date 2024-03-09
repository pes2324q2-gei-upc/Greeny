# Generated by Django 5.0.3 on 2024-03-07 08:27

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='User',
            fields=[
                ('nom', models.CharField(verbose_name='Nom')),
                ('username', models.CharField(primary_key=True, serialize=False, verbose_name='Username')),
                ('password', models.CharField(verbose_name='Password')),
                ('email', models.EmailField(max_length=254, verbose_name='Email')),
            ],
            options={
                'verbose_name_plural': 'Users',
            },
        ),
    ]