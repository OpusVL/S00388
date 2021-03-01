FROM python:3.9.2-alpine3.12

LABEL maintainer="Paul Bargewell <paul.bargewell@opusvl.com>"

RUN adduser -H -D www-data

RUN mkdir -p /var/www/html && \
  chown www-data: /var/www -R && \
  chmod 755 /var/www -R

ADD --chown=www-data /html /var/www/html

EXPOSE 8080

VOLUME /var/www/html

USER www-data

COPY docker-entrypoint.py /usr/local/bin/docker-entrypoint.py

COPY ./html/index.html /var/www/html/index.html

WORKDIR /var/www/html

ENTRYPOINT [ "python3", "/usr/local/bin/docker-entrypoint.py" ]