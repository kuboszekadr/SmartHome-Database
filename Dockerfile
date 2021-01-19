FROM postgres:13.1

RUN apt-get update && apt-get -y install pgagent

COPY src/model.sql src/model.sql
COPY src/data.sql src/data.sql

COPY create_extension.sh /docker-entrypoint-initdb.d
COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && ln -s /usr/local/bin/entrypoint.sh /

ENTRYPOINT ["entrypoint.sh"]
CMD ["postgres"]