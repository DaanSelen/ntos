FROM alpine:latest

LABEL maintainer="dselen@nerthus.nl"

# Install Apache & Bash
RUN apk update && apk add --no-cache apache2 bash

# Suppress the ServerName warning
RUN echo "ServerName localhost" >> /etc/apache2/httpd.conf

COPY entrypoint.sh /entrypoint.sh
COPY ntos /var/www/localhost/htdocs/

EXPOSE 80

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]