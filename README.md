[![logo](https://raw.githubusercontent.com/michaelbaudino/nginx-letsencrypt-reverse-proxy/master/logo.png)](https://github.com/michaelbaudino/nginx-letsencrypt-reverse-proxy)

# Nginx + Let's Encrypt reverse proxy as a Docker container

[![Docker Automated build](https://img.shields.io/docker/automated/michaelbaudino/nginx-letsencrypt-reverse-proxy.svg?style=flat-square)](https://hub.docker.com/r/michaelbaudino/nginx-letsencrypt-reverse-proxy/)
[![Docker Stars](https://img.shields.io/docker/stars/michaelbaudino/nginx-letsencrypt-reverse-proxy.svg?style=flat-square)](https://hub.docker.com/r/michaelbaudino/nginx-letsencrypt-reverse-proxy/)
[![Docker Pulls](https://img.shields.io/docker/pulls/michaelbaudino/nginx-letsencrypt-reverse-proxy.svg?style=flat-square)](https://hub.docker.com/r/michaelbaudino/nginx-letsencrypt-reverse-proxy/)

Simple Docker container with Nginx configured to force HTTPS (thanks to Let's Encrypt) to any given HTTP backend server (configured via the `$BACKEND` environment variable).

## Setup

Before starting an instance of this container, you need to install Let's Encrypt certificates:
```
docker run -p 80:80 michaelbaudino/nginx-letsencrypt-reverse-proxy letsencrypt-install --domain <example.com> --email <root@example.com>
```

:information_source: Port 80 must not be already bound by another process/server and must be accessible from the outside world for this procedure to work.

The `--staging` switch can be appended for testing purposes: it retrieves certificates from the staging Let's Encrypt server to avoid reaching the production server rate limit.

Any valid `letsencrypt` switches can actually been appended to this command: they will be passed as is to `letsencrypt`. Check out [`letsencrypt` documentation](https://certbot.eff.org/docs/using.html) for more details.

## Usage

### Using Docker Engine (_a.k.a._ just "Docker")

From your beloved shell, just type the following to start an instance in the foreground:
```
docker run -p 80:80 -p 443:443 -v letsencrypt-data:/etc/letsencrypt/ -e BACKEND="<backend_url>" michaelbaudino/nginx-letsencrypt-reverse-proxy
```

Where `<backend_url>` should be replaced by your application URL in Nginx format (_i.e._ without protocol)

If you'd rather start an instance running in the background, just add the `-d` switch (and eventually name your instance using the `--name` switch).

Nginx logs are available using the [`docker logs` command](https://docs.docker.com/engine/reference/commandline/logs/).

Renew Let's Encrypt certificates with (the container must be already running):
```
docker exec -it <container> letsencrypt-renew [--staging] [--force-renewal]
```

Where `<container>` is either the container ID (as shown by `docker ps`) or the container name (as assigned with the `--name` switch of `docker run`).

### Using Docker Compose

Adapt this sample `docker-compose.yml` file to your own needs:
```yaml
version: "2"
volumes:
  letsencrypt-data:
    driver: local
services:
  nginx:
    image: michaelbaudino/nginx-letsencrypt-reverse-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - letsencrypt-data:/etc/letsencrypt/
    depends_on:
      - your-backend
    environment:
      BACKEND: "your-backend:8080"
  your-backend:
    image: ...
    ports:
      - "8080:8080"
```

Then just run as usual using `docker-compose up` :tada: :whale:

Renew Let's Encrypt certificates with (the container must be already running):
```
docker-compose exec nginx letsencrypt-renew [--staging] [--force-renewal]
```

# Development

1. Clone this repository
2. Do your changes
3. Build with `docker build .`
4. If other people might benefit your changes, please submit a pull request

# License

This code is distributed under the MIT license terms (see [LICENSE.md](https://github.com/michaelbaudino/nginx-letsencrypt-reverse-proxy/blob/master/LICENSE.md)).

Logos concatenated in [logo.svg](https://github.com/michaelbaudino/nginx-letsencrypt-reverse-proxy/blob/master/logo.svg) are trademarks of their respective owners ([Docker Inc.](https://www.docker.com/company), [Nginx Inc.](https://www.nginx.com/company/) and [Internet Security Research Group](https://letsencrypt.org/)).
