#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Building the development image...${NC}"
docker-compose -f docker-compose.yml up -d --build
docker-compose -f docker-compose.yml exec shelly-plug-influxdb-dev composer install -d /app/
docker-compose down
echo -e "${GREEN}Done!${NC}"
