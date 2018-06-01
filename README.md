# ASGS
## Codebase for the ASGS-Monitor prototype

This is a Django project

### Installation:

Perquisites:
* Python3
* Django >= 2
* django-cors-headers


Config steps:
```
=> delete 0001 file 
=> python3 manage.py makemigrations ASGS_Mon
=> python3 manage.py sqlmigrate ASGS_Mon 0001
=> python3 manage.py migrate
=> manage.py runserver 0.0.0.0:8000 
```

Import test data
```
=> sqlite db.sqlite3 
sqlite> .read Docs/Insert_lu_records.sql
sqlite> .read Docs/test_events_and_messages.sql
```
