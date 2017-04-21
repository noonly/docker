#!/bin/bash
jsons="{\"service\":{\"name\":\"$SERVICE_NAME\",\"tags\":[\"database\",\"mysql\"],\"port\":3306}}"
echo $jsons >> /tmp/service.json

