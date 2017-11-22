FROM ubuntu:16.04

MAINTAINER Michael Baudino <michael.baudino@alpine-lab.com>

# disable source repositories
RUN sed -i 's/^deb-src/# deb-src/' /etc/apt/sources.list

# install required packages
RUN apt-get update \
 && apt-get install --no-install-recommends --no-install-suggests -y \
      nginx \
      letsencrypt \
 && rm -rf /var/lib/apt/lists/*

# disable default nginx config
RUN rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

# add nginx config files
COPY nginx-config/* /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/* /etc/nginx/sites-enabled/

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

# copy letsencrypt wrapper scripts
COPY bin/letsencrypt-* /usr/local/bin/

# expose HTTP(S) ports
EXPOSE 80 443

ENV HSTS true

# entrypoint that takes care of replacing placeholders in nginx
# configuration files with values from environment variables
# (works with both docker-compose `up` and `run` commands)
COPY nginx-config-replacer /usr/local/bin/
ENTRYPOINT ["nginx-config-replacer"]

# start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
