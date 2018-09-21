#FROM rocker/r-ver:3.5.1
FROM ubuntu:16.04

MAINTAINER Kamil Foltynski "kamil.foltynski@contractors.roche.com"

## --------- Install R
ARG BUILD_DATE
ENV BUILD_DATE ${BUILD_DATE:-2018-09-18}

RUN apt-get update && apt-get install -y \
    gdebi-core \
    wget \
    procps \
    sudo

# source: https://www.digitalocean.com/community/tutorials/how-to-install-r-on-ubuntu-18-04
RUN sh -c 'echo "deb http://cloud.r-project.org/bin/linux/ubuntu trusty-cran35/" >> /etc/apt/sources.list' && \
    gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
    gpg -a --export E084DAB9 | sudo apt-key add - && \
    apt-get update && \
    apt-get -y install r-base

#RUN apt --fix-broken install
#RUN apt-get install rrdtool psmisc libapparmor1 libedit2 sudo

RUN INST_DIR=$(mktemp -d /tmp/shiny-pro-XXXXXX) && \
    cd $INST_DIR && \
    wget https://s3.amazonaws.com/rstudio-shiny-server-pro-build/ubuntu-14.04/x86_64/shiny-server-commercial-1.5.9.988-amd64.deb && \
    echo "y" | gdebi shiny-server-commercial-1.5.9.988-amd64.deb && \
    rm -rf $INST_DIR

## supervisord

RUN apt-get update -y && apt-get install -y \
    openssl \
    supervisor \
    passwd

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor && chmod 777 -R /var/log/supervisor
COPY run_supervisord.sh /opt/bin/run_supervisord.sh
ENTRYPOINT ["bash", "/opt/bin/run_supervisord.sh"]

EXPOSE 3838 4151

# Administrative dashboard is running on port 4151
# set password for admin user
RUN echo "admin" | /opt/shiny-server/bin/sspasswd /etc/shiny-server/passwd admin

## Set up S6 init system
RUN wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    rm -rf /tmp/https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz
  
CMD ["/init"]


