FROM alpine

LABEL org.opencontainers.image.source https://github.com/davidbarratt/backup-sqlite

ENV S3_ACCESS_KEY=
ENV S3_SECRET_KEY=
ENV S3_BUCKET=

RUN apk add --no-cache  \
    python3 \
    py3-pip \
    libmagic \
    sqlite

RUN pip install \
    python-magic \
    s3cmd 

RUN mkdir /opt/backup

COPY backup.sh /opt/backup.sh

RUN chmod +x /opt/backup.sh

CMD "/opt/backup.sh"