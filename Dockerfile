FROM alpine:3.8

ENV ADMIN_USERNAME Admin
ENV ADMIN_PASSWORD PASSWORD
ENV DOMAIN example.com

RUN apk add --no-cache openldap openldap-back-mdb openldap-overlay-memberof tini \
 && mkdir -p /run/openldap

COPY slapd.conf /etc/openldap/

RUN HASHED_PASSWORD=$(slappasswd -s $ADMIN_PASSWORD) \
 && DN="dc="$(echo $DOMAIN|sed 's/\./,dc=/g') \
 && sed -i "s/%ADMIN_USERNAME/${ADMIN_USERNAME}/g" /etc/openldap/slapd.conf \
 && sed -i "s/%ADMIN_PASSWORD/${HASHED_PASSWORD}/g" /etc/openldap/slapd.conf \
 && sed -i "s/%DN/${DN}/g" /etc/openldap/slapd.conf

CMD tini -- slapd -d3 -f /etc/openldap/slapd.conf
#RUN slapd -f /etc/openldap/slapd.conf