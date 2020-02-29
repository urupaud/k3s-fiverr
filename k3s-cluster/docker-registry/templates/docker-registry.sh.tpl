#!/bin/bash

apt-get update
apt install -y gnupg2 pass apache2-utils httpie
apt install -y docker.io docker-compose -y
systemctl start docker
systemctl enable docker
mkdir -p registry/{nginx,auth}
cd registry/
mkdir -p nginx/{conf.d/,ssl}
cat <<EOF > docker-compose.yml
version: '3'
services:

#Registry
  registry:
    image: registry:2
    restart: always
    ports:
    - "5000:5000"
    environment:
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: Registry-Realm
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/registry.passwd
      REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data
    volumes:
      - registrydata:/data
      - ./auth:/auth
    networks:
      - mynet

#Nginx Service
  nginx:
    image: nginx:alpine
    container_name: nginx
    restart: unless-stopped
    tty: true
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d/:/etc/nginx/conf.d/
      - ./nginx/ssl/:/etc/nginx/ssl/
    networks:
      - mynet

#Docker Networks
networks:
  mynet:
    driver: bridge
#Volumes
volumes:
  registrydata:
    driver: local
EOF

cat <<'EOF' > auth/registry.passwd
${docker-resgitry-credentials}
EOF

cat <<'EOF' > nginx/conf.d/registry.conf
upstream docker-registry {
    server registry:5000;
}

server {
    listen 80;
    server_name ${docker-registry-fqdn};
    return 301 https://${docker-registry-fqdn}$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${docker-registry-fqdn};

    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/private.key;

    # Log files for Debug
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;

    location / {
        # Do not allow connections from docker 1.5 and earlier
        # docker pre-1.6.0 did not properly set the user agent on ping, catch "Go *" user agents
        if ($http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*$" )  {
            return 404;
        }

        proxy_pass                          http://docker-registry;
        proxy_set_header  Host              $http_host;
        proxy_set_header  X-Real-IP         $remote_addr;
        proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header  X-Forwarded-Proto $scheme;
        proxy_read_timeout                  900;
    }

}
EOF

cat <<EOF > nginx/conf.d/additional.conf
client_max_body_size 2G;
EOF

cat <<EOF > nginx/ssl/private.key
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCjGs0Cn4cbJhjX
BffDaFeonxdZS1afkk17a0RYc51SaYzU9seI5VnSV8pDnkZqORyar3i7E/YYMwvu
RbXCYfq7Nqs8kyw9Z8uS05rDhZnOvUumJ0C63SIDlHlKogxnnPExDZOXyDfoOA29
E0wUziuol3EKBCYXDbDJRDCwkRCPQ5NBxDJKMq/ELls6jKp3bmP5+dnCdVFLCKxt
QvgXePndly5jOpaA2fP8MzL7j3AaNk5UC1Dkd7cmqAJe9pdFI3ojh1zVbUYbL8y5
Nh21/z7Hq/9qac7nKBdbIGy19mNRDd790sX/6SXhaupr8IC5/g53EP3aXfm81G6D
H/JUP5MXAgMBAAECggEATtPBmA50c/0GDUmflEul7eMxnCDKlSVWmBrf9aWut2k2
vKgmCDXcIsn2AZcJbgX7GpFKlpOPoONu1THQpcjHrlo+CPER9P1oiCYHio5TpvSa
josy//ymlzdXJWhK+XqCoNPwbG9CAdOxZBti7j00IW9LnO0jYYnm0mbH51W8vJfF
HC4sE12qrJDHcgNRlNWNPFnr1w+oYqa9TAYZQHmMXghlivSssmBeqd0nypkxtKmq
HL+12nDk6vNX0a3sjCunbEgIxy8e5JZ7B0MjwdhFLZ9fQKhHMjw9j4qii0YfIcqA
gsBRoYY0wZrDNN4I4rEKK7+BX9IIdYYejhyXpWby/QKBgQDMvw5+qfvl9tCwBUYC
9WKrkm7QodXqSkdfCBsTmSvQWuE7xvf4fQMEqQnS89YcxGc7x5/groa34tVR7ZPD
KIdDL16hb5MFk6H9syrA7jS+x+l/U22nWQMXRT9EXjd27k/HF4OCbjOE7YW5exIr
/AMVOhqo8TAEbayZ94QP9bLUKwKBgQDL7y+yQ31w21lUEp3CIFkPljbLav5V3JCZ
CWy6i3YWyGlrEpoYugSRcfL+ujN5L8DuEaokKmTCZ7w+/0q/wmRgTd3jTaNnYVdP
zLGif/pjb73vTNzJowrRnwJU1Vus7UuO7p+ykzXJPL0E0Ek+bLITLCUuQwyZghIJ
Bd8G+pnqxQKBgGmWGZ5+gLX+C27KuWkrLIA4WsdivhM9zQKYBoab1flz9HVETXqq
1VSg670LHB7ntikg8DUJK9ZGtyWx9CKPkvm1wwJTrKkSklZoACNQdIjyRVrxJjpH
8A0fG9phEA9YJHISkTJBLHZfmzek3SErrFdVCIyZHN8bxAf+me81EMzTAoGALNC5
SJFwRZbOgJ0+seRt7fDyxa0Ti0bXN+pMTIpNPyB3miISXxCx5EyIO9YrbZxC545W
N3BhiB9HzQhJIu7TJB64fjUXjaZki5LODonVOnjZ4nafpmf//qTU3FOuu8fB7P0f
dxzGmxyP5Tjof6FfWLtAyHPPlwRwdi8mHeCAZokCgYBO4xVbYh0ofC7yo9gxunGM
g/BHt0NIXLusSUSmg0GrZWvTWMqSTMm0grfZQNRvEs9a/Vq6f52qhUTnhNggdWI2
Rd/MZjutCERTE2Zn00DpSdGQOAHkNDYXgKfZbXM7BM2o5JIC/U8S5T+xWSlbnCNz
IjnhBk+Kcrlj/FBj2pDo5w==
-----END PRIVATE KEY-----
EOF

cat <<EOF > nginx/ssl/server.crt
-----BEGIN CERTIFICATE-----
MIIFUjCCBDqgAwIBAgISA8nOh121DDxkyFzwU+LLFdzmMA0GCSqGSIb3DQEBCwUA
MEoxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MSMwIQYDVQQD
ExpMZXQncyBFbmNyeXB0IEF1dGhvcml0eSBYMzAeFw0yMDAyMTUwNzEyNDVaFw0y
MDA1MTUwNzEyNDVaMBMxETAPBgNVBAMMCCouZW1pLnBlMIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEAoxrNAp+HGyYY1wX3w2hXqJ8XWUtWn5JNe2tEWHOd
UmmM1PbHiOVZ0lfKQ55Gajkcmq94uxP2GDML7kW1wmH6uzarPJMsPWfLktOaw4WZ
zr1LpidAut0iA5R5SqIMZ5zxMQ2Tl8g36DgNvRNMFM4rqJdxCgQmFw2wyUQwsJEQ
j0OTQcQySjKvxC5bOoyqd25j+fnZwnVRSwisbUL4F3j53ZcuYzqWgNnz/DMy+49w
GjZOVAtQ5He3JqgCXvaXRSN6I4dc1W1GGy/MuTYdtf8+x6v/amnO5ygXWyBstfZj
UQ3e/dLF/+kl4Wrqa/CAuf4OdxD92l35vNRugx/yVD+TFwIDAQABo4ICZzCCAmMw
DgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAM
BgNVHRMBAf8EAjAAMB0GA1UdDgQWBBQuXJl8Zb9n+4tkw3laWbjszvyiizAfBgNV
HSMEGDAWgBSoSmpjBH3duubRObemRWXv86jsoTBvBggrBgEFBQcBAQRjMGEwLgYI
KwYBBQUHMAGGImh0dHA6Ly9vY3NwLmludC14My5sZXRzZW5jcnlwdC5vcmcwLwYI
KwYBBQUHMAKGI2h0dHA6Ly9jZXJ0LmludC14My5sZXRzZW5jcnlwdC5vcmcvMBsG
A1UdEQQUMBKCCCouZW1pLnBlggZlbWkucGUwTAYDVR0gBEUwQzAIBgZngQwBAgEw
NwYLKwYBBAGC3xMBAQEwKDAmBggrBgEFBQcCARYaaHR0cDovL2Nwcy5sZXRzZW5j
cnlwdC5vcmcwggEGBgorBgEEAdZ5AgQCBIH3BIH0APIAdwDnEvKwN34aYvuOyQxh
hPHqezfLVh0RJlvz4PNL8kFUbgAAAXBH6DZAAAAEAwBIMEYCIQDIDfPGUr2CXjIB
JGWpOJouXyOv6ZPFY9As0onsvSxeIgIhAK5JFE2esJfm7Mncqtg2QIcZLubJDd1p
LMFqiu+1QCwdAHcAB7dcG+V9aP/xsMYdIxXHuuZXfFeUt2ruvGE6GmnTohwAAAFw
R+g2lgAABAMASDBGAiEA8TgcvtiWKPrrmW16ulEa+wEDi3kDFfodsxsVd/OxfpAC
IQC69kx/duqXkCxfg8+d80Ki7P4urHlJ+xxKQXfONziNpjANBgkqhkiG9w0BAQsF
AAOCAQEAOLKE6fkuVR2uark9XZSI7f/1mh/SofOkmx23TWYobsLFUVRCNzfX85Vk
y6+OgO7gL4rzxFIhkzGm9n7CViZj0x0rjtCsUuMtqs5LW2KgA8d2q0Jk9hImEFzS
TQjuWjnPOaTLqWTeqdhqba+P08Iho8GbgqbKHxp3ast3xW5t9Py6E1qc/Qgx+lS1
J9MwDfeqIaoiWpXT/fmeXtz9q7ChJJ6APMlP3sbKW5ywBSZak3MEwite6BcntsS2
hl+vGXIzjGasdwuoHdcEe7iH8/iqmoTR8s0e2xNT2WTwocAfkuUl1e/3VjdCvXKe
FWdWMENShzpurwb2zBJsSBi4ikPUog==
-----END CERTIFICATE-----

-----BEGIN CERTIFICATE-----
MIIEkjCCA3qgAwIBAgIQCgFBQgAAAVOFc2oLheynCDANBgkqhkiG9w0BAQsFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTE2MDMxNzE2NDA0NloXDTIxMDMxNzE2NDA0Nlow
SjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxIzAhBgNVBAMT
GkxldCdzIEVuY3J5cHQgQXV0aG9yaXR5IFgzMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEAnNMM8FrlLke3cl03g7NoYzDq1zUmGSXhvb418XCSL7e4S0EF
q6meNQhY7LEqxGiHC6PjdeTm86dicbp5gWAf15Gan/PQeGdxyGkOlZHP/uaZ6WA8
SMx+yk13EiSdRxta67nsHjcAHJyse6cF6s5K671B5TaYucv9bTyWaN8jKkKQDIZ0
Z8h/pZq4UmEUEz9l6YKHy9v6Dlb2honzhT+Xhq+w3Brvaw2VFn3EK6BlspkENnWA
a6xK8xuQSXgvopZPKiAlKQTGdMDQMc2PMTiVFrqoM7hD8bEfwzB/onkxEz0tNvjj
/PIzark5McWvxI0NHWQWM6r6hCm21AvA2H3DkwIDAQABo4IBfTCCAXkwEgYDVR0T
AQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwfwYIKwYBBQUHAQEEczBxMDIG
CCsGAQUFBzABhiZodHRwOi8vaXNyZy50cnVzdGlkLm9jc3AuaWRlbnRydXN0LmNv
bTA7BggrBgEFBQcwAoYvaHR0cDovL2FwcHMuaWRlbnRydXN0LmNvbS9yb290cy9k
c3Ryb290Y2F4My5wN2MwHwYDVR0jBBgwFoAUxKexpHsscfrb4UuQdf/EFWCFiRAw
VAYDVR0gBE0wSzAIBgZngQwBAgEwPwYLKwYBBAGC3xMBAQEwMDAuBggrBgEFBQcC
ARYiaHR0cDovL2Nwcy5yb290LXgxLmxldHNlbmNyeXB0Lm9yZzA8BgNVHR8ENTAz
MDGgL6AthitodHRwOi8vY3JsLmlkZW50cnVzdC5jb20vRFNUUk9PVENBWDNDUkwu
Y3JsMB0GA1UdDgQWBBSoSmpjBH3duubRObemRWXv86jsoTANBgkqhkiG9w0BAQsF
AAOCAQEA3TPXEfNjWDjdGBX7CVW+dla5cEilaUcne8IkCJLxWh9KEik3JHRRHGJo
uM2VcGfl96S8TihRzZvoroed6ti6WqEBmtzw3Wodatg+VyOeph4EYpr/1wXKtx8/
wApIvJSwtmVi4MFU5aMqrSDE6ea73Mj2tcMyo5jMd6jmeWUHK8so/joWUoHOUgwu
X4Po1QYz+3dszkDqMp4fklxBwXRsW10KXzPMTZ+sOPAveyxindmjkW8lGy+QsRlG
PfZ+G6Z6h7mjem0Y+iWlkYcV4PIWL1iwBi8saCbGS5jN2p8M+X+Q7UNKEkROb3N6
KOqkqm57TH2H3eDJAkSnh6/DNFu0Qg==
-----END CERTIFICATE-----
EOF

docker-compose up -d