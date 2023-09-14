# Generated by Django 3.2.9 on 2023-08-29 07:05

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('appmsw', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='param',
            name='lang',
        ),
        migrations.AddField(
            model_name='param',
            name='paropt',
            field=models.CharField(choices=[('sys', 'System Parameter'), ('app', 'Application Parameter'), ('prj', 'Project')], default='app', max_length=30),
        ),
    ]