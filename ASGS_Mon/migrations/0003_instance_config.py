# Generated by Django 2.0.8 on 2019-01-04 17:28

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('ASGS_Mon', '0002_instance_instance_name'),
    ]

    operations = [
        migrations.CreateModel(
            name='Instance_config',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('adcirc_config', models.TextField()),
                ('asgs_config', models.TextField()),
                ('instance', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='ASGS_Mon.Instance')),
            ],
        ),
    ]
