# PostgreSQL with PgAgent installed

The aim of this repository is to allow you to run PostgreSQL database together with pgAgent in one container. 
PgAgent gives you ability to run recurring jobs inside database.

> Note: This is rather dedicated to `dev` environments.

### Build the image
#
```sh
$ docker build . -t postgres-pgagent:10
```

### Run the image
#
```sh
$ docker run -d -p 5432:5432 
    -e POSTGRES_USER=user1 -e POSTGRES_PASSWORD=pass123 \
    -v pgdata:/var/lib/postgresql/data \
    --restart=alway \
    postgres-pgagent:10
```
