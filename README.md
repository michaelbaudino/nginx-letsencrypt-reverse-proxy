[![logo](https://rawgit.com/michaelbaudino/nginx-letsencrypt-reverse-proxy/master/logo.svg)](https://github.com/michaelbaudino/nginx-letsencrypt-reverse-proxy)

[![Docker Stars](https://img.shields.io/docker/stars/michaelbaudino/nginx-letsencrypt-reverse-proxy.svg?style=flat-square)](https://hub.docker.com/r/michaelbaudino/nginx-letsencrypt-reverse-proxy/)
[![Docker Pulls](https://img.shields.io/docker/pulls/michaelbaudino/nginx-letsencrypt-reverse-proxy.svg?style=flat-square)](https://hub.docker.com/r/michaelbaudino/nginx-letsencrypt-reverse-proxy/)
[![Docker Automated build](https://img.shields.io/docker/automated/michaelbaudino/nginx-letsencrypt-reverse-proxy.svg?style=flat-square)](https://hub.docker.com/r/michaelbaudino/nginx-letsencrypt-reverse-proxy/)

Easy-to-use Docker container with Nginx configured to force HTTPS (thanks to Let's Encrypt) to any given HTTP backend server (configured via the `$BACKEND` environment variable).

## Usage with Docker Engine (_a.k.a._ just "Docker")

### Setup

Before starting an instance of this container, you need to install Let's Encrypt certificates:
```
docker run -p 80:80 -v letsencrypt-data:/etc/letsencrypt/ \
  michaelbaudino/nginx-letsencrypt-reverse-proxy \
  letsencrypt-install --domain <example.com> --email <root@example.com>
```

> :information_source: Port 80 must not be already bound by another process/server and must be accessible from the outside world for this procedure to work.

### Run

To start an instance in foreground, use the following command:
```
docker run -p 80:80 -p 443:443 -v letsencrypt-data:/etc/letsencrypt/ -e BACKEND="<backend_url>" michaelbaudino/nginx-letsencrypt-reverse-proxy
```

Where `<backend_url>` should be replaced by your application address [in Nginx format](https://nginx.org/en/docs/http/ngx_http_upstream_module.html#server), which is pretty much an URL without protocol (_e.g._ `some.backend.com:8080`) or a Unix socket prefixed with `unix:` (_e.g._ `unix:/var/run/backend.sock`).

> :bulb: If you'd rather start an instance running in the background, just add the `-d` switch (and eventually name your instance using the `--name` switch for easier later use).

> :bulb: Nginx logs are available using the [`docker logs` command](https://docs.docker.com/engine/reference/commandline/logs/).

### Renew

To renew Let's Encrypt certificates, run (the container must be already running):
```
docker exec -it <container> letsencrypt-renew
```

Where `<container>` is either the container ID (as shown by `docker ps`) or the container name (as assigned with the `--name` switch of `docker run`).

## Usage with Docker Compose

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

### Setup

Before starting an instance of this container, you need to install Let's Encrypt certificates:
```
docker-compose run nginx --service-ports --no-deps letsencrypt-install --domain <example.com> --email <root@example.com>
```

> :information_source: Port 80 must not be already bound by another process/server and must be accessible from the outside world for this procedure to work.

### Run

Just run as usual using:
```
docker-compose up
```

:whale: :tada:

### Renew

To renew Let's Encrypt certificates, run (the container must be already running):
```
docker-compose exec nginx letsencrypt-renew
```

# Development

1. Clone this repository
2. Do your changes
3. Build with `docker build .`
4. If other people might benefit your changes, please submit a pull request

### Staging Let's Encrypt server

The `--staging` switch can be appended to both `letsencrypt-install` and `letsencrypt-renew` commands for testing purposes: it retrieves certificates from the staging Let's Encrypt server to avoid reaching the production server **rate limit**.

The `letsencrypt-renew` command also takes an optional `--force-renew` switch (to renew certificates regardless their expiration date).

> :bulb: Any valid `letsencrypt` / `certbot` switches can actually been appended to both `letsencrypt-install` and `letsencrypt-renew` commands: they will be passed as is. Check out [`letsencrypt` / `certbot` documentation](https://certbot.eff.org/docs/using.html) for more details.

### Internal network

If your Docker host is on an internal network (behind a router, not directly connected to Internet), you will need to add a NAT rule to your router configuration to redirect traffic on port 80 from the outside world to your private IP address.

Since the ACME protocol requires the use of port 80, there's no way to use another port.

# License

This code is distributed under the MIT license terms (see [LICENSE.md](https://github.com/michaelbaudino/nginx-letsencrypt-reverse-proxy/blob/master/LICENSE.md)).

Logos concatenated in [logo.svg](https://github.com/michaelbaudino/nginx-letsencrypt-reverse-proxy/blob/master/logo.svg) are trademarks of their respective owners ([Docker Inc.](https://www.docker.com/company), [Nginx Inc.](https://www.nginx.com/company/) and [Internet Security Research Group](https://letsencrypt.org/)).
