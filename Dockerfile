FROM odoo:12
LABEL maintainer="Nonpawit Teerachetmongkol <nonpawit.tee@aginix.tech>"

# Copy to Workdir
COPY ./requirements.txt ./

# Install requirements
RUN pip3 install -r requirements.txt

# Copy to root directory
COPY ./entrypoint.sh /

# Odoo addons
COPY ./local-src /odoo/local-src
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
