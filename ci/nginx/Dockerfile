ARG NGINX_IMAGE=nginx:stable-alpine
FROM $NGINX_IMAGE

COPY nginx/nginx.conf  /etc/nginx/nginx.conf
COPY nginx/startup.sh  /opt/startup.sh
COPY assets            /opt/www/public
COPY build/index-src   /opt/index-src

RUN rm /opt/www/public/*-local.yaml

EXPOSE 8080

ENTRYPOINT ["/opt/startup.sh"]
