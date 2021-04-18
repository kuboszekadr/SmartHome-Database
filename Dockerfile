FROM debian:10.9

COPY src/model.sql src/model.sql

# install necesary packages
RUN apt-get update &&\
    apt-get install -y postgresql-11 &&\
    apt-get install -y pgagent

# allow external connections
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/11/main/pg_hba.conf
RUN echo "host all  all    ::/0  md5" >> /etc/postgresql/11/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/11/main/postgresql.conf

# switch to postgres user and alter password
USER postgres
RUN /etc/init.d/postgresql start &&\
    psql -c "ALTER USER postgres WITH PASSWORD 'postgres'"&&\
    psql -f src/model.sql -U "postgres"

EXPOSE 5432
CMD ["/usr/lib/postgresql/11/bin/postgres", "-D", "/var/lib/postgresql/11/main", "-c", "config_file=/etc/postgresql/11/main/postgresql.conf"]