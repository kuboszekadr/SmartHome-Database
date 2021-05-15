FROM debian:10.9

# install necesary packages
RUN apt-get update &&\
    apt-get install -y postgresql-11 &&\
    apt-get install -y pgagent

# set relevant postgresql env variables

COPY src/model.sql src/model.sql
COPY ./entrypoint.sh /usr/local/bin/

# add priviliges 
RUN chmod 777 /usr/local/bin/entrypoint.sh \
    && ln -s /usr/local/bin/entrypoint.sh /

ENV PATH $PATH:/usr/lib/postgresql/11/bin/
ENV PGDATA /var/lib/postgresql/11/main

# allow external connections
RUN echo "host all  all 0.0.0.0/0  md5" >> /etc/postgresql/11/main/pg_hba.conf &&\
    echo "host all  all ::/0  md5" >> /etc/postgresql/11/main/pg_hba.conf &&\
    echo "listen_addresses='*'" >> /etc/postgresql/11/main/postgresql.conf

USER postgres
# switch to postgres user and alter password
RUN /etc/init.d/postgresql start &&\
    psql -c "ALTER USER postgres WITH PASSWORD 'postgres'"&&\
    psql -f src/model.sql -U "postgres" -q

STOPSIGNAL SIGINT

EXPOSE 5432
CMD ["entrypoint.sh"]