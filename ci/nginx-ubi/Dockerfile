FROM registry.access.redhat.com/ubi8/ubi-minimal

LABEL name="kabanero-index" \
      vendor="Kabanero" \
      version="1" \
      release="1" \
      summary="Nginx container to host Kabanero collections" \
      description="Nginx container to host Kabanero collections"

COPY nginx-ubi/nginx.repo  /etc/yum.repos.d/nginx.repo

RUN microdnf install nginx findutils \
    && mkdir /var/cache/nginx \
    && chown -R nginx:0 /var/log/nginx/ /var/cache/nginx /usr/share/nginx \
    && chmod -R g=u /var/log/nginx/ /var/cache/nginx /usr/share/nginx \
    && mkdir /licenses \
    && cp /usr/share/doc/nginx*/* /licenses
