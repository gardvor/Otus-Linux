FROM alpine:latest
RUN apk update
RUN apk add nginx
RUN adduser -D -g 'www' www
RUN mkdir /www
RUN chown -R www:www /var/lib/nginx
RUN chown -R www:www /www
COPY nginx.conf /etc/nginx/
COPY index.html /www/
CMD ["nginx", "-g", "daemon off;"]