#!/bin/bash

set -e

SERVER_KEY=/tmp/server.key
SERVER_CERT=/tmp/server.crt

openssl genrsa -out $SERVER_KEY 2048
openssl req -new -x509 -key $SERVER_KEY -out $SERVER_CERT -days 365 -subj /C=US/ST=NRW/L=Earth/O=CompanyName/OU=IT/CN=www.example.com/emailAddress=email@example.com

echo '{"server_cert": "'$SERVER_CERT'", "server_key": "'$SERVER_KEY'"}'