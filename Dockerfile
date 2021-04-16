FROM timbru31/ruby-node:2.7 as builder

RUN mkdir /usr/src/app
WORKDIR /usr/src/app
ENV PATH /usr/src/app/node_modules/.bin:$PATH
COPY package.json /usr/src/app/package.json

RUN npm install -g bower
RUN npm install -g grunt-cli
COPY . /usr/src/app
RUN bower --allow-root install
RUN npm install
RUN bundle install
RUN grunt prod

FROM nginx:1.19.3
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /usr/src/app/dist/community-app /usr/share/nginx/html/mifosx
RUN sed -i 's/listen       80/listen       8080/g' /etc/nginx/conf.d/default.conf
RUN chown -R nginx.nginx /run /var/cache/nginx /docker-entrypoint.d /docker-entrypoint.sh /etc/nginx
EXPOSE 8080
USER nginx

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
