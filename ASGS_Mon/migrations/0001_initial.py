# Generated by Django 2.0.4 on 2018-05-01 14:56

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Event',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('event_ts', models.DateTimeField()),
                ('nodes_in_use', models.IntegerField()),
                ('nodes_available', models.IntegerField()),
                ('raw_data', models.CharField(max_length=4000)),
            ],
        ),
        migrations.CreateModel(
            name='Event_type_lu',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=50)),
                ('description', models.CharField(max_length=100)),
            ],
        ),
        migrations.CreateModel(
            name='Message',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('advisory_id', models.CharField(max_length=50)),
                ('storm_name', models.CharField(max_length=50)),
                ('storm_number', models.CharField(max_length=50)),
                ('message', models.CharField(max_length=250)),
                ('other', models.CharField(max_length=250)),
            ],
        ),
        migrations.CreateModel(
            name='Message_type_lu',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=50)),
                ('description', models.CharField(max_length=100)),
            ],
        ),
        migrations.CreateModel(
            name='Site_lu',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=50)),
                ('description', models.CharField(max_length=100)),
                ('cluster_name', models.CharField(max_length=100)),
                ('nodes', models.IntegerField()),
                ('tech_contact', models.CharField(max_length=100)),
                ('location', models.CharField(max_length=100)),
            ],
        ),
        migrations.AddField(
            model_name='message',
            name='message_type',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='ASGS_Mon.Message_type_lu'),
        ),
        migrations.AddField(
            model_name='event',
            name='event_type',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='ASGS_Mon.Event_type_lu'),
        ),
        migrations.AddField(
            model_name='event',
            name='message',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='ASGS_Mon.Message'),
        ),
        migrations.AddField(
            model_name='event',
            name='site',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='ASGS_Mon.Site_lu'),
        ),
    ]