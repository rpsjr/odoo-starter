#FROM raimundopsjr/docker-odoo-br:13.0.1
#FROM code137oficial/docker-odoo-base:13.0
FROM odoo:13
LABEL maintainer="rpsjr@github"

# Copy to Workdir
COPY ./requirements.txt ./

# Install requirements
RUN pip3 install -r requirements.txt

# Copy to root directory
COPY ./entrypoint.sh /

# Odoo addons
COPY ./local-src /odoo/local-src
ADD https://github.com/rpsjr/payment_boletointer/archive/master.zip /odoo/local-src
ADD https://github.com/rpsjr/l10n_br_base/archive/master.zip /odoo/local-src
COPY ./external-src /odoo/external-src
COPY ./addons /mnt/extra-addons
RUN chown odoo /mnt/extra-addons

COPY ./config /etc/odoo

EXPOSE 8080

# Set default user when running the container
USER odoo

ENV PORT 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
