FROM ubuntu:18.04 as base
ENV DEBIAN_FRONTEND=noninteractive

# install required packages
RUN apt-get update && apt-get install -y software-properties-common curl git

# configure user
RUN add-apt-repository ppa:ondrej/php

RUN apt-get update && \
    apt-get install -y \
    php8.0-cli \
    php8.0-zip \
    php8.0-curl && \
    php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer && \
    mkdir /run/php && \
    apt-get -y autoremove && apt-get clean

RUN mkdir /app

# configure "crontab"
COPY schedule.sh /schedule.sh
RUN chmod +x /schedule.sh

from base as development

WORKDIR /app

ENTRYPOINT ["/schedule.sh"]

FROM base as production

RUN git clone https://github.com/knobik/shelly-plug-influxdb.git /app && \
    composer install --no-dev -d /app

WORKDIR /app

ENTRYPOINT ["/schedule.sh"]
