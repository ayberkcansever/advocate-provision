FROM nginx:alpine
LABEL maintainer Tony Pitale <tpitale@gmail.com>

RUN mkdir -p /etc/nginx/sites-enabled /app/log /app/public

# TODO: create our nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY advocate.template /etc/nginx/advocate.template

CMD /bin/sh -c "envsubst '\$ADVOCATE_SERVERS \$ADVOCATE_BRIDGE_SERVERS' < /etc/nginx/advocate.template > /etc/nginx/sites-enabled/advocate && nginx"
