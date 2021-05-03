
databases=`mysql --skip-column-names --silent --host="database" --user="$MYSQL_USER" --password="$MYSQL_PASSWORD"  -e "SHOW DATABASES;"`

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        tables=`mysql --skip-column-names --silent --host="database" --user="$MYSQL_USER" --password="$MYSQL_PASSWORD"  -e "SHOW TABLES FROM $db"`
        for table in $tables; do
            mkdir /opt/backup/$db;
            mysqldump \
                --skip-dump-date \
                --host="database" \
                --user="$USER" \
                --password="$PASSWORD" \
                $db $table > /opt/backup/$db/$table.sql;
        done
    fi
done

s3cmd \
    --host="nyc3.digitaloceanspaces.com" \
    --host-bucket="%(bucket)s.nyc3.digitaloceanspaces.com" \
    --access_key="$S3_ACCESS_KEY" \
    --secret_key="$S3_SECRET_KEY" \
    --delete-removed \
    --acl-private \
    --default-mime-type="application/sql" \
    sync /opt/backup/ s3://$S3_BUCKET/backup/;
