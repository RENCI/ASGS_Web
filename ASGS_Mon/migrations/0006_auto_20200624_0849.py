# Generated by Django 2.0.4 on 2020-06-24 12:49

import django.contrib.postgres.fields.jsonb
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('ASGS_Mon', '0005_event_subpctcomplete'),
    ]

    operations = [
        migrations.CreateModel(
            name='Config_item',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('key', models.CharField(max_length=255)),
                ('value', models.CharField(max_length=1024)),
                ('instance', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='ASGS_Mon.Instance')),
            ],
        ),
        migrations.AlterField(
            model_name='json',
            name='id',
            field=models.AutoField(primary_key=True, serialize=False),
        ),
        migrations.AlterField(
            model_name='user_pref',
            name='filter_site',
            field=django.contrib.postgres.fields.jsonb.JSONField(null=True),
        ),
        migrations.AlterField(
            model_name='user_pref',
            name='home_site',
            field=models.IntegerField(null=True),
        ),
    ]
