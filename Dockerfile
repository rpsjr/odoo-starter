#FROM raimundopsjr/docker-odoo-br:13.0.1
#FROM code137oficial/docker-odoo-base:13.0
FROM odoo:13
LABEL maintainer="rpsjr@github"

# Copy to Workdir
COPY ./requirements.txt ./


USER root
RUN whoami

RUN pip3 install --upgrade pip

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    apt-utils

# xmlsec native libraries
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libxml2-dev \
    libxmlsec1-dev \
    libxmlsec1-openssl \
    python3-xmlsec

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
        unzip \
        git \
        python3-setuptools \
        python3-wheel \
        python3-cryptography \
        pkg-config \
        && rm -rf /var/lib/apt/lists/*


# Install requirements

RUN pip3 install -r requirements.txt
RUN pip3 install --no-cache-dir https://github.com/kmee/febraban-python/archive/feature/improve-user-model.zip
RUN pip3 install --no-cache-dir git+https://github.com/rpsjr/erpbrasil.bank.inter.git

USER odoo

# Copy to root directory
COPY ./entrypoint.sh /

# Odoo addons
COPY ./local-src /odoo/local-src
COPY ./external-src /odoo/external-src
COPY ./addons /mnt/extra-addons

RUN cd /odoo/external-src
    wget https://github.com/Trust-Code/odoo-brasil/archive/13.0.zip -O odoo-brasil.zip && \
    wget https://github.com/Code-137/odoo-apps/archive/13.0.zip -O odoo-apps.zip && \
    wget https://github.com/oca/server-ux/archive/13.0.zip -O server-ux.zip && \
    wget https://github.com/oca/reporting-engine/archive/13.0.zip -O reporting-engine.zip && \
    wget https://github.com/oca/account-financial-reporting/archive/13.0.zip -O account-financial-reporting.zip && \
    wget https://github.com/oca/mis-builder/archive/13.0.zip -O mis-builder.zip && \
		wget https://github.com/OCA/bank-payment/archive/13.0.zip -O bank-payment.zip && \
		wget https://github.com/OCA/account-payment/archive/13.0.zip -O account-payment.zip && \
		wget https://github.com/OCA/account-financial-tools/archive/13.0.zip -O account-financial-tools.zip && \
		wget https://github.com/OCA/server-tools/archive/13.0.zip -O server-tools.zip && \
    wget https://github.com/Trust-Code/helpdesk/archive/13.0.zip -O helpdesk.zip && \
    unzip -q odoo-brasil.zip && rm odoo-brasil.zip && mv odoo-brasil-13.0 odoo-brasil && rm -rf odoo-brasil/l10n_br_base && \
    unzip -q odoo-apps.zip && rm odoo-apps.zip && mv odoo-apps-13.0 odoo-apps && \
    unzip -q server-ux.zip && rm server-ux.zip && mv server-ux-13.0 server-ux && \
    unzip -q reporting-engine.zip && rm reporting-engine.zip && mv reporting-engine-13.0 reporting-engine && \
    unzip -q account-financial-reporting.zip && rm account-financial-reporting.zip && mv account-financial-reporting-13.0 account-financial-reporting && \
    unzip -q mis-builder.zip && rm mis-builder.zip && mv mis-builder-13.0 mis-builder && \
		unzip -q bank-payment.zip && rm bank-payment.zip && mv bank-payment-13.0 bank-payment && \
		unzip -q account-payment.zip && rm account-payment.zip && mv account-payment-13.0 account-payment && \
		unzip -q account-financial-tools.zip && rm account-financial-tools.zip && mv account-financial-tools-13.0 account-financial-tools && \
		unzip -q server-tools.zip && rm server-tools.zip && mv server-tools-13.0 server-tools && \
    unzip -q helpdesk.zip && rm helpdesk.zip && mv helpdesk-13.0 helpdesk

RUN cd /odoo/external-src
    wget https://github.com/OCA/website/archive/13.0.zip -O website.zip && \
		wget https://github.com/muk-it/muk_base/archive/13.0.zip -O muk_base.zip && \
		wget https://github.com/muk-it/muk_web/archive/13.0.zip -O muk_web.zip && \
		wget https://github.com/rpsjr/fleet_management/archive/13.0.zip -O fleet_management.zip  && \
		wget https://github.com/OCA/partner-contact/archive/13.0.zip -O partner-contact.zip  && \
		wget https://github.com/OCA/fleet/archive/13.0.zip -O fleet.zip  && \
		wget https://github.com/rpsjr/payment_boletointer/archive/master.zip -O payment_boletointer.zip  && \
		wget https://github.com/rpsjr/l10n_br_base/archive/master.zip -O l10n_br_base.zip && \
		wget https://github.com/OCA/contract/archive/13.0.zip -O contract.zip && \
    unzip -q website.zip && rm website.zip && mv website-13.0 website && \
		unzip -q muk_base.zip && rm muk_base.zip && mv muk_base-13.0 muk_base && \
		unzip -q muk_web.zip && rm muk_web.zip && mv muk_web-13.0 muk_web && \
		unzip -q fleet_management.zip && rm fleet_management.zip && mv fleet_management-13.0 fleet_management && \
		unzip -q partner-contact.zip && rm partner-contact.zip && mv partner-contact-13.0 partner-contact && \
		unzip -q fleet.zip && rm fleet.zip && mv fleet-13.0 fleet && \
		unzip -q payment_boletointer.zip && rm payment_boletointer.zip && mv payment_boletointer-master payment_boletointer && \
		unzip -q l10n_br_base.zip && rm l10n_br_base.zip && mv l10n_br_base-master l10n_br_base && \
		unzip -q contract.zip && rm contract.zip && mv contract-13.0 contract

RUN chown -R odoo /odoo/external-src
RUN chown -R odoo /odoo/local-src
RUN chown -R odoo /mnt/extra-addons

COPY ./config /etc/odoo

EXPOSE 8080

# Set default user when running the container
#USER odoo
USER root

ENV PORT 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
