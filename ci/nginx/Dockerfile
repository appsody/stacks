ARG NGINX_IMAGE=registry.access.redhat.com/ubi7/ubi-minimal
FROM $NGINX_IMAGE

LABEL name="collections-host" \
      vendor="Appsody" \
      version="0.1.0" \
      release="1" \
      summary="Nginx host for stack" \
      description="Nginx container to host stack"

COPY nginx/nginx.repo  /etc/yum.repos.d/nginx.repo

RUN microdnf install nginx

COPY nginx/LICENSE     /licenses/
COPY nginx/nginx.conf  /etc/nginx/nginx.conf
COPY nginx/startup.sh  /opt/startup.sh
COPY assets            /opt/www/public
COPY build/prefetch    /opt/www/public
COPY build/index-src   /opt/index-src

RUN rm /opt/www/public/*-local.yaml

EXPOSE 8080

RUN touch /var/run/nginx.pid && \
  chown -R nginx:0 /var/run/nginx.pid /var/cache/nginx /opt/www/public /etc/nginx /run && \
  chmod -R g=u /opt/www/public /var/cache/nginx /etc/nginx /var/run/nginx.pid /run

USER nginx

ENTRYPOINT ["/opt/startup.sh"]
