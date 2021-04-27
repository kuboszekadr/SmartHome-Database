FROM debian:10.9

COPY src/model.sql src/model.sql
COPY ./entrypoint.sh /usr/local/bin/

# install necesary packages
RUN apt-get update &&\
    apt-get install -y postgresql-11 &&\
    apt-get install -y pgagent

# set relevant postgresql env variables
ENV PATH $PATH:/usr/lib/postgresql/11/bin/
ENV PGDATA /var/lib/postgresql/11/main

# allow external connections
RUN echo "host all  all 0.0.0.0/0  md5" >> /etc/postgresql/11/main/pg_hba.conf &&\
    echo "host all  all ::/0  md5" >> /etc/postgresql/11/main/pg_hba.conf &&\
    echo "listen_addresses='*'" >> /etc/postgresql/11/main/postgresql.conf

# switch to postgres user and alter password
USER postgres
RUN /etc/init.d/postgresql start &&\
    psql -c "ALTER USER postgres WITH PASSWORD 'postgres'"&&\
    psql -f src/model.sql -U "postgres" -q

EXPOSE 5432

CMD ["entrypoint.sh"]