FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive

# install required packages
RUN apt-get update && apt-get install -y software-properties-common curl git

# configure user
RUN add-apt-repository ppa:ondrej/php

RUN apt-get update && \
    apt-get install -y \
    php8.0-cli \
    php8.0-curl \
    php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer && \
    mkdir /run/php && \
    apt-get -y autoremove && apt-get clean

RUN git clone git@github.com:knobik/shelly-plug-influxdb.git /app && \
    composer install -d /app

# configure crontab
COPY schedule.sh /schedule.sh
RUN chmod +X /schedule.sh

ENTRYPOINT ["/schedule.sh"]