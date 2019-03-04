#
# asgs_dashboard tables
# to see stats, determine why indexes arent being hit and generate vac/analyze statements
#
# select 
#    'echo "vac/analyze ' || schemaname || '.' || relname || '"' || E'\n' || 'psql -d asgs_dashboard -c ''vacuum full analyze verbose ' || schemaname || '."' || relname || '";'''
# 	 ,*  
# from pg_stat_user_tables 
# where 
#	 schemaname = 'public'
# order by 4,5 desc
#
           
date

echo "vac/analyze public.ASGS_Mon_event"
psql -d asgs_dashboard -c 'vacuum full analyze verbose public."ASGS_Mon_event";'

echo "vac/analyze public.ASGS_Mon_event_group"
psql -d asgs_dashboard -c 'vacuum full analyze verbose public."ASGS_Mon_event_group";'

echo "vac/analyze public.ASGS_Mon_instance"
psql -d asgs_dashboard -c 'vacuum full analyze verbose public."ASGS_Mon_instance";'

echo "vac/analyze public.ASGS_Mon_instance_config"
psql -d asgs_dashboard -c 'vacuum full analyze verbose public."ASGS_Mon_instance_config";'

#
# Django admin tables
#
date

echo "vac/analyze public.auth_user"
psql -d asgs_dashboard -c 'vacuum full analyze verbose public."auth_user";'

echo "vac/analyze public.django_session"
psql -d asgs_dashboard -c 'vacuum full analyze verbose public."django_session";'

date
