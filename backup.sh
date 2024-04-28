
set -e;

databases=`mysql --skip-column-names --silent --host="database" --user="$MYSQL_USER" --password="$MYSQL_PASSWORD"  -e "SHOW DATABASES;"`

if [[ -z "$BUCKET" ]]; then
    echo "Must provide BUCKET in environment" 1>&2
    exit 1
fi

mkdir -p "/opt/OneDrive/Backup/$BUCKET";

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        tables=`mysql --skip-column-names --silent --host="database" --user="$MYSQL_USER" --password="$MYSQL_PASSWORD"  -e "SHOW TABLES FROM $db"`
        for table in $tables; do
            mkdir -p /opt/OneDrive/Backup/$BUCKET/$db;
            mysqldump \
                --skip-dump-date \
                --host="database" \
                --user="$MYSQL_USER" \
                --password="$MYSQL_PASSWORD" \
                $db $table > /opt/OneDrive/Backup/$BUCKET/$db/$table.sql;
        done
    fi
done

onedrive \
    --synchronize \
    --upload-only \
    --syncdir="/opt/OneDrive" \
    --single-directory="Backup/$BUCKET"
