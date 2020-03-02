#Copyright 2020 Cloudbase Solutions SRL.
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
<VirtualHost *:443>

    SSLEngine on
    SSLproxyEngine on
    SSLCertificateFile {{ .Values.conf.coriolis_web_proxy.proxy_ssl_certs_dir }}/coriolis.crt
    SSLCertificateKeyFile {{ .Values.conf.coriolis_web_proxy.proxy_ssl_certs_dir }}/coriolis.key

    Header always set Access-Control-Allow-Origin "*"
    Header always set Access-Control-Allow-Methods "POST, GET, OPTIONS, DELETE, PUT, PATCH"
    Header always set Access-Control-Max-Age "1000"
    Header always set Access-Control-Allow-Headers "x-requested-with, X-Auth-Token, X-Subject-Token, Content-Type, origin, authorization, accept, client-security-token"
    Header always set Access-Control-Allow-Credentials "true"
    Header add Access-Control-Expose-Headers "X-Subject-Token"
    # Added a rewrite to respond with a 200 SUCCESS on every OPTIONS request.
    RewriteEngine On

    # Define coriolis_logger_ws_url {{/* coriolis_logger_ws_url */}}

    # RewriteCond %{HTTP:Upgrade} =websocket [NC]
    # RewriteRule "^/log-stream(/?.*)$"  "${coriolis_logger_ws_url}$1" [P,L]

    # ProxyRequests off
    # <Location /log-stream>
    #      ProxyPass        "${coriolis_logger_ws_url}"
    #      ProxyPassReverse "${coriolis_logger_ws_url}"
    # </Location>

    RewriteCond %{HTTP:Upgrade} !=websocket [NC]

    RewriteCond %{REQUEST_METHOD} OPTIONS
    RewriteRule ^(.*)$ $1 [R=200,L]

    # Define logger_endpoint {{/* coriolis_logger_endpoint */}}
    Define keystone_auth_url {{ tuple "identity" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
    Define barbican_endpoint {{ tuple "key-manager" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
    Define coriolis_base_url {{ tuple "migration" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
    # Define licensing_server_endpoint {{/* tuple "identity" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" */}}
    # Define licensing_ui_endpoint {{/* tuple "identity" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" */}}
    # Define web_ui_base_url {{/* tuple "identity" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" */}}

    # Proxy matches paths to appropiate services
    # RewriteRule "^/logs(/?.*)$" "${logger_endpoint}/logs$1" [P]
    RewriteRule "^/identity(/?.*)$" "${keystone_auth_url}$1" [P]
    RewriteRule "^/barbican(/?.*)$" "${barbican_endpoint}$1" [P]
    RewriteRule "^/coriolis(/?.*)$" "${coriolis_base_url}$1" [P]
    # RewriteRule "^/licensing-ui(/?.*)$" "${licensing_ui_endpoint}$1" [P]
    # RewriteRule "^/licensing(/?.*)$" "${licensing_server_endpoint}$1" [P]
    # RewriteRule "^/((?!identity|coriolis|barbican|licensing|licensing-ui).*)$" "${web_ui_base_url}/$1" [P]

</VirtualHost>

<VirtualHost *:80>
    RewriteEngine On
    RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]
</VirtualHost>
