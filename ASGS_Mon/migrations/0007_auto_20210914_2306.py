# Generated by Django 2.0.8 on 2021-09-14 23:06

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('ASGS_Mon', '0006_auto_20200624_0849'),
    ]

    operations = [
        migrations.CreateModel(
            name='Supervisor_config',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('job_name', models.CharField(max_length=50)),
                ('data_volume_name', models.CharField(max_length=50)),
                ('ssh_volume_name', models.CharField(max_length=50)),
                ('image', models.CharField(max_length=50)),
                ('command_line', models.CharField(max_length=50)),
                ('command_matrix', models.CharField(max_length=50)),
                ('data_mount_path', models.CharField(max_length=50)),
                ('ssh_mount_path', models.CharField(max_length=50)),
                ('sub_path', models.CharField(max_length=50)),
                ('additional_path', models.CharField(max_length=50)),
                ('memory', models.CharField(max_length=50)),
                ('node_type', models.CharField(max_length=50)),
            ],
        ),
        migrations.CreateModel(
            name='Supervisor_job_location_lu',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=50)),
                ('description', models.CharField(max_length=100)),
            ],
        ),
        migrations.CreateModel(
            name='Supervisor_job_type_lu',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=50)),
                ('description', models.CharField(max_length=100)),
            ],
        ),
        migrations.AddField(
            model_name='supervisor_config',
            name='job_location',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='ASGS_Mon.Supervisor_job_location_lu'),
        ),
        migrations.AddField(
            model_name='supervisor_config',
            name='job_type',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='job_types', to='ASGS_Mon.Supervisor_job_type_lu'),
        ),
        migrations.AddField(
            model_name='supervisor_config',
            name='next_job_type',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='next_job_types', to='ASGS_Mon.Supervisor_job_type_lu'),
        ),
    ]