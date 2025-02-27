# python: 3.10.6
# pgadmin: 6.13.0
FROM python:3.10.6-bullseye
MAINTAINER Florian Schroeder <schroeder.florian@gmail.com>

# create a non-privileged user to use at runtime
RUN addgroup --system --gid 51 pgadmin \
 && adduser --system --disabled-password --home /pgadmin --shell /sbin/nologin --uid 1000 --gid 51 pgadmin \
 && mkdir -p /pgadmin/config /pgadmin/storage \
 && chown -R 1000:51 /pgadmin \
 && chmod g=u /etc/passwd

# Install postgresql tools for backup/restore
RUN apt update \
 && apt install -y postgresql-client dos2unix \
 && apt autoremove -y \
 && apt clean

ENV PGADMIN_VERSION=6.13
ENV PYTHONDONTWRITEBYTECODE=1

RUN pip install --upgrade --no-cache-dir pip \
 && echo "https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v${PGADMIN_VERSION}/pip/pgadmin4-6.13-py3-none-any.whl" | pip install --no-cache-dir -r /dev/stdin \
 && pip install --no-cache-dir --upgrade Flask-WTF

EXPOSE 5050

COPY LICENSE config_distro.py /usr/local/lib/python3.10/site-packages/pgadmin4/
COPY entrypoint.sh /usr/local/bin/

RUN chmod ug=rwx /usr/local/bin/entrypoint.sh \
 && dos2unix /usr/local/bin/entrypoint.sh

USER pgadmin:pgadmin
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD ["python", "./usr/local/lib/python3.10/site-packages/pgadmin4/pgAdmin4.py"]
VOLUME /pgadmin/
