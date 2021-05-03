FROM python:3.7-slim-buster

COPY ./s6-overlay-amd64.tar.gz /tmp/s6-overlay-amd64.tar.gz

RUN apt-get update \
    && apt-get install -y logrotate cron apt-utils vim curl \
    && mkdir /logs \
    && tar xfz /tmp/s6-overlay-amd64.tar.gz \
    && rm -rf /tmp/*

COPY ./rootfs /

RUN apt-get install -y apache2 apache2-utils libapache2-mod-wsgi-py3
ADD ./sonar.conf /etc/apache2/sites-available/000-default.conf
ADD ./proxy.conf /etc/apache2/sites-available/proxy.conf
ADD ./sonar_ssl.conf /etc/apache2/sites-available/000-default-ssl.conf
ADD ./apache2_logrotate /etc/logrotate.d/apache2

RUN /usr/sbin/a2enmod ssl
RUN /usr/sbin/a2enmod proxy
RUN /usr/sbin/a2enmod proxy_http
RUN /usr/sbin/a2enmod rewrite
RUN cd /etc/apache2/sites-available/
RUN /usr/sbin/a2ensite proxy.conf
RUN /usr/sbin/a2ensite 000-default-ssl.conf

EXPOSE 80 443
ENTRYPOINT ["/init"]
CMD []
