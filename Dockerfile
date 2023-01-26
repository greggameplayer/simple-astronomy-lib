FROM maven:3.8.7-eclipse-temurin-8

ENV HOME=/opt/workspace

RUN set -eux; \
    addgroup --system --gid 1000 astronomy; \
    adduser --system --home ${HOME} -u 1000 --gid 1000 astronomy; \
    mkdir -p ${HOME}; \
    chown -R astronomy:astronomy ${HOME} \
    cd ${HOME};

COPY --chown=astronomy:astronomy ./target/SimpleAstronomyLib-*.jar ${HOME}/bin/

WORKDIR ${HOME}
CMD ["sleep 99d"]
