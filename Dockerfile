FROM alpine:3.4

MAINTAINER gmunoz1979@gmail.com

ENV POSTGRESQL_VERSION 9.5
ENV POSTGIS_VERSION 2.2.2
ENV GEOS_VERSION 3.5.0
ENV PROJ4 4.9.2
ENV GDAL 2.1.1
ENV PGDATA /var/lib/postgresql/data

RUN apk update && \
    apk add postgresql postgresql-client postgresql-contrib postgresql-dev \
	    perl libxml2-dev alpine-sdk g++ autoconf automake libtool gzip \
            nano

RUN cd /tmp && wget http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2 && \
    tar xvfj geos-${GEOS_VERSION}.tar.bz2 && \
    cd geos-${GEOS_VERSION} && \
    ./configure --enable-silent-rules CFLAGS="-D__sun -D__GNUC__"  CXXFLAGS="-D__GNUC___ -D__sun" && \
    make && make install

RUN cd /tmp && wget http://download.osgeo.org/proj/proj-${PROJ4}.tar.gz && \
    tar xvfz proj-${PROJ4}.tar.gz && \
    cd proj-${PROJ4} && \
    ./configure --enable-silent-rules && make && make install

RUN cd /tmp && wget http://download.osgeo.org/gdal/${GDAL}/gdal-${GDAL}.tar.gz && \
    tar xvfz gdal-${GDAL}.tar.gz && \
    cd gdal-${GDAL} && \
    ./configure --enable-silent-rules && make && make install

RUN cd /tmp && wget http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz && \
    tar xvfz /tmp/postgis-${POSTGIS_VERSION}.tar.gz && \
    cd postgis-${POSTGIS_VERSION} && \
    ./configure --enable-silent-rules --with-projdir=/usr/local && make && make install

RUN cd /tmp && rm geos-${GEOS_VERSION}.tar.bz2 && rm -r geos-${GEOS_VERSION} && \
    rm proj-${PROJ4}.tar.gz              && rm -r proj-${PROJ4}              && \
    rm gdal-${GDAL}.tar.gz               && rm -r gdal-${GDAL}               && \
    rm postgis-${POSTGIS_VERSION}.tar.gz && rm -r postgis-${POSTGIS_VERSION} && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /etc/postgresql && \
    cp /usr/share/postgresql/postgresql.conf.sample /etc/postgresql/postgresql.conf && \
    cp /usr/share/postgresql/pg_hba.conf.sample     /etc/postgresql/pg_hba.conf

#RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/pg_hba.conf && \
#s    echo "listen_addresses='*'" >> /etc/postgresql/postgresql.conf     

ENV LANG en_US.utf8

RUN mkdir -p ${PGDATA} && \
    chown postgres:postgres ${PGDATA}
    chmod 700 ${PGDATA}

VOLUME ${PGDATA}

USER postgres

RUN initdb -D ${PGDATA} && \
    /usr/bin/postgres -c config_file=/etc/postgresql/postgresql.conf

EXPOSE 5432

CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
