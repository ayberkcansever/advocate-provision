FROM nginx:alpine
LABEL maintainer Tony Pitale <tpitale@gmail.com>

RUN mkdir -p /etc/nginx/sites-enabled /app/log /app/public

# TODO: create our nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY advocate.template /etc/nginx/advocate.template

ARG ADVOCATE_SERVER=advocate.dev
ENV ADVOCATE_SERVER=$ADVOCATE_SERVER
RUN envsubst '\$ADVOCATE_SERVER' < /etc/nginx/advocate.template > /etc/nginx/sites-enabled/advocate

CMD nginx
