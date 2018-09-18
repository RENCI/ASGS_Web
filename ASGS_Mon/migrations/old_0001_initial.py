# Generated by Django 2.0.4 on 2018-06-07 17:34

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
                ('advisory_id', models.CharField(max_length=50)),
                ('pct_complete', models.IntegerField()),
                ('process', models.CharField(max_length=100)),
                ('host_start_file', models.CharField(max_length=1000)),
                ('raw_data', models.CharField(max_length=4000)),
            ],
        ),
        migrations.CreateModel(
            name='Event_group',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('event_group_ts', models.DateTimeField()),
                ('storm_name', models.CharField(max_length=50)),
                ('storm_number', models.CharField(max_length=50)),
                ('advisory_id', models.CharField(max_length=50)),
                ('final_product', models.CharField(max_length=1000)),
            ],
        ),
        migrations.CreateModel(
            name='Event_type_lu',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=50)),
                ('description', models.CharField(max_length=100)),
                ('view_order', models.IntegerField()),
                ('pct_complete', models.IntegerField()),
            ],
        ),
        migrations.CreateModel(
            name='Site_lu',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=50)),
                ('description', models.CharField(max_length=100)),
                ('cluster_name', models.CharField(max_length=100)),
                ('tech_contact', models.CharField(max_length=100)),
                ('phys_location', models.CharField(max_length=100)),
            ],
        ),
        migrations.CreateModel(
            name='State_type_lu',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=50)),
                ('description', models.CharField(max_length=100)),
                ('view_order', models.IntegerField()),
            ],
        ),
        migrations.AddField(
            model_name='site_lu',
            name='state_type',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='ASGS_Mon.State_type_lu'),
        ),
        migrations.AddField(
            model_name='event_group',
            name='site',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='ASGS_Mon.Site_lu'),
        ),
        migrations.AddField(
            model_name='event_group',
            name='state_type',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='ASGS_Mon.State_type_lu'),
        ),
        migrations.AddField(
            model_name='event',
            name='event_group',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='ASGS_Mon.Event_group'),
        ),
        migrations.AddField(
            model_name='event',
            name='event_type',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='ASGS_Mon.Event_type_lu'),
        ),
        migrations.AddField(
            model_name='event',
            name='site',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='ASGS_Mon.Site_lu'),
        ),
    ]
