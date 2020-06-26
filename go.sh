#!/bin/bash

./req-online-certs.sh test predex.duckdns.org
./req-online-certs.sh request predex.duckdns.org gjlendrino.box@gmail.com
./test-online-cert.sh predex.duckdns.org

