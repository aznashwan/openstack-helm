#!/bin/bash

{{/*
Copyright 2020 Cloudbase Solutions SRL.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex
COMMAND="${@:-start}"

function start () {
    CERTDIR="{{ .Values.conf.coriolis_web_proxy.proxy_ssl_certs_dir }}"
    exec openssl req -new -newkey rsa:4096 -days 820 -nodes -x509 \
        -subj "/C=RO/ST=Timis/L=Timisoara/CN=Coriolis Self Signed" \
        -keyout "$CERTDIR/coriolis.key" -out "$CERTDIR/coriolis.crt"
}

function stop () {
  kill -TERM 1
}

$COMMAND
