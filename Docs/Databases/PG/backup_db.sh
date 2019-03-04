#
# backs up databases.
#
# should be run as a cronjob nightly at midnight (local), e.g. 
# 0 21 * * * postgres /<dir>/backups.sh

BASE_DIR=/<dir>
DUMPS_DIR=$BASE_DIR/backups
LOG_DIR=$DUMPS_DIR/log

if [ -e $LOG_DIR/export.log ]; then
    rm $LOG_DIR/export.log
fi

date >> $LOG_DIR/export.log

for i in `psql -c "SELECT datname FROM pg_databasewhere datname in ('asgs_dashboard', 'asgs_testdb')" | head -n -2 | tail -n +3`; do
    for j in {8..1}; do
        DUMP_FILE=$DUMPS_DIR/$i.dump.$j
        NEW_DUMP_FILE=$DUMPS_DIR/$i.dump.$(( j + 1 ))
        if [ -e $DUMP_FILE ]; then
            echo "mv $DUMP_FILE $NEW_DUMP_FILE" >> $LOG_DIR/export.log
            mv $DUMP_FILE $NEW_DUMP_FILE
        fi
    done
done

for i in `psql -c "SELECT datname FROM pg_database where datname in ('asgs_dashboard', 'asgs_testdb')" | head -n -2 | tail -n +3`; do
    if [ -e $DUMPS_DIR/$i.dump.8 ]; then
        echo "removing $DUMPS_DIR/$i.dump.8" >> $LOG_DIR/export.log
        rm $DUMPS_DIR/$i.dump.8
    fi
    echo "dumping...$DUMPS_DIR/$i.dump.1" >> $LOG_DIR/export.log
    date >> $LOG_DIR/export.log
    pg_dump -d $i -Fc -f $DUMPS_DIR/$i.dump.1
    date >> $LOG_DIR/export.log
done
