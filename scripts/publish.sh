#!/bin/bash 

echo "Rebuilding site..."
npm run build
rsync -avp --delete -e ssh public/ kismetwireless.net:www/
