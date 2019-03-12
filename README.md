# Let's Encrypt Wildcard Service

This image is heavily based on the [csmith/letsencrypt-lexicon](https://hub.docker.com/r/csmith/letsencrypt-lexicon)
image.

This container will automatically obtain SSL certs from [Let's Encrypt](https://letsencrypt.org/)
using the ACME v2 protocol and verifying the challenge using dns-01. This means this
image will work properly for wildcard certs.

Multiple domains, as well as SANs, are supported. Certificates will be
renewed automatically, and obtained automatically as soon as new domains
are added.

## Usage

### Registering and accepting Let's Encrypt's terms

In order to issue certificates with Let's Encrypt, you must registerr and agree to the
Let's Encrypt terms of service. You can do this by running the command
`/dehydrated --register --accept-terms` from within the container. I suggest you use
docker-compose, which means you can just do the following:
`docker-compose run letsencrypt /dehydrated --register --accept-terms`.

For ease of automation, you can define the `ACCEPT_CA_TERMS` env var
(with any non-empty value) to automatically accept the terms. Be warned
that doing so will automatically accept any future changes to the terms
of service.

### Defining domains

The container defines one volume at `/letsencrypt`, and expects there to be
a list of domains in `/letsencrypt/domains.txt`. Certificates are output to
`/letsencrypt/certs/{domain}`.

domains.txt should contain one line per certificate. If you want alternate
names on the cert, these should be listed after the primary domain. e.g.

```
example.com *.example.com
domain.com www.domain.com
```

This will request two certificates: a wildcard domain for example.com and one
for domain.com with a SAN of www.domain.com.

The container uses inotify to monitor the domains.txt file for changes,
so you can update it while the container is running and changes will be
automatically applied.

### DNS providers

To verify that you own the domain, a TXT record needs to be automatically
created for it. The [Lexicon](https://github.com/AnalogJ/lexicon) library handles this, and comes with support
for a variety of providers.

Lexicon takes its configuration from environment variables. For full
instructions, see its
[README](https://github.com/AnalogJ/lexicon/blob/master/README.md).

For example, to configure Lexicon to update DNS hosted by CloudFlare, you
would pass in:

```
docker run ... \
  -e "PROVIDER=cloudflare" \
  -e "LEXICON_CLOUDFLARE_USERNAME=email@address.com" \
  -e "LEXICON_CLOUDFLARE_TOKEN=api-key-here"
```

### Other configuration

For testing purposes, you can set the `STAGING` environment variable to
a non-empty value. This will use the Let's Encrypt staging server, which
has much more relaxed limits.

You should pass in a contact e-mail address by setting the `EMAIL` env var.
This is passed on to Let's Encrypt, and may be used for important service
announcements.

### Running

Here's a full worked example:

```bash
# The directory we'll use to store the domain list and certificates.
# You could use a docker volume instead.
mkdir /tmp/letsencrypt
echo "example.com *.example.com" > /tmp/letsencrypt/domains.txt

docker run -d --restart=always \
  -e "EMAIL=admin@domain.com" \
  -e "STAGING=true" \
  -e "PROVIDER=cloudflare" \
  -e "LEXICON_CLOUDFLARE_USERNAME=email@address.com" \
  -e "LEXICON_CLOUDFLARE_TOKEN=api-key-here" \
  -v /tmp/letsencrypt:/letsencrypt \
  fhriley/letsencrypt-wildcard:latest
```

An example docker-compose.yml:

```letsencrypt:
  image: fhriley/letsencrypt-wildcard:latest
  container_name: letsencrypt
  hostname: letsencrypt
  restart: always
  volumes:
    - /tmp/letsencrypt:/letsencrypt
  environment:
    - EMAIL=email@domain.com
    - STAGING=true
    - ACCEPT_CA_TERMS=true
    - PROVIDER=cloudflare
    - LEXICON_CLOUDFLARE_USERNAME=email@domain.com
    - LEXICON_CLOUDFLARE_TOKEN=api-key-here```