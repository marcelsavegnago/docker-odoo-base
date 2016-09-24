FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV TERM=xterm
# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

	##### Dependências #####

ADD conf/apt-requirements /opt/sources/
ADD conf/pip-requirements /opt/sources/

WORKDIR /opt/sources/
RUN apt-get update && apt-get install -y python-pip locales supervisor && \
    pip install --no-cache-dir --upgrade pip && \
    apt-get install -y --no-install-recommends $(grep -v '^#' apt-requirements) && \
    npm install -g less && npm cache clean && \
    pip install --no-cache-dir -r pip-requirements

ADD http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb /opt/sources/wkhtmltox.deb
RUN dpkg -i wkhtmltox.deb && \
    locale-gen en_US en_US.UTF-8 pt_BR.UTF-8 && \
    dpkg-reconfigure locales

ENV LC_ALL pt_BR.UTF-8

	##### Repositórios TrustCode e OCB #####

WORKDIR /opt/odoo/
RUN mkdir private

	##### Configurações Odoo #####

ADD conf/supervisord.conf /etc/supervisor/supervisord.conf

RUN mkdir /var/log/odoo && \
    mkdir /opt/dados && \
    mkdir /opt/xml && \
    mkdir /opt/xml/imp && \
    mkdir /opt/xml/exp && \
    mkdir /opt/xml/bkp && \
    mkdir /var/log/supervisord && \
    touch /var/log/odoo/odoo.log && \
    touch /var/run/odoo.pid && \
    ln -s /opt/odoo/OCB/openerp-server /usr/bin/odoo-server && \
    ln -s /etc/odoo/odoo.conf && \
    ln -s /var/log/odoo/odoo.log && \
    useradd --system --home /opt --shell /bin/bash odoo && \
    chown -R odoo:odoo /opt && \
    chown -R odoo:odoo /var/log/odoo && \
    chown odoo:odoo /var/run/odoo.pid

	##### Limpeza da Instalação #####

RUN apt-get autoremove -y && \
    apt-get autoclean

	##### Finalização do Container #####

WORKDIR /opt/odoo
