FROM python:3.7-alpine
MAINTAINER Frank Riley <fhriley@gmail.com> 

RUN apk add --no-cache curl libffi openssl libxml2 libxslt inotify-tools bash sed grep coreutils && \
    apk add --no-cache --virtual .build-deps libffi-dev openssl-dev libxml2-dev libxslt-dev build-base && \
    pip install --no-cache-dir requests[security] dns-lexicon[full] && \
    apk del .build-deps

COPY dehydrated run.sh dehydrated.default.sh /
RUN chmod +x /dehydrated /run.sh /dehydrated.default.sh

COPY dehydrated_config /config

VOLUME ["/letsencrypt"]

ENTRYPOINT ["/bin/bash"]
CMD ["/run.sh"]
