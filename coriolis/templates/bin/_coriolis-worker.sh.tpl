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

{{- $envAll := . }}

set -ex
COMMAND="${@:-start}"

function start () {
  exec coriolis-api \
{{- range $prv := $envAll.Values.providers.source }}
        {{- printf "--config-file /etc/coriolis/plugins/%s_migration_provider.conf \\" $prv }}
{{- end }}
{{- range $prv := $envAll.Values.providers.destination }}
{{- if not (has $prv $envAll.Values.providers.source) }}
        {{- printf "--config-file /etc/coriolis/plugins/%s_migration_provider.conf \\" $prv }} 
{{- end }}
{{- end }}
        --config-file /etc/coriolis/coriolis.conf
{{/*
# NOTE(aznashwan): `concat` does not work in Helm < 3 so we need to double-iterate like above ^
{{- range $prv := concat .Values.providers.source .Values.providers.destination | uniq}}
        {{- printf "--config-file /etc/coriolis/plugins/%s_migration_provider.conf" $prv }}
{{- end }}
}
*/}}

function stop () {
  kill -TERM 1
}

$COMMAND
