FROM maven:3.8.7-eclipse-temurin-8

ENV HOME=/opt/workspace

RUN set -eux; \
    addgroup -S -g 1000 astronomy; \
    adduser -S -D -u 1000 -G astronomy astronomy; \
    mkdir -p ${HOME}; \
    chown -R astronomy:astronomy ${HOME} \
    cd ${HOME};

COPY --chown=astronomy:astronomy ./target/SimpleAstronomyLib-*.jar ${HOME}/bin/

WORKDIR ${HOME}
CMD ["sleep 99d"]
