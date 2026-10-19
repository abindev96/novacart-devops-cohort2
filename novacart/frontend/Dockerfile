FROM nginx:1.27-alpine

COPY index.html app.js styles.css /usr/share/nginx/html/

COPY docker/nginx.conf /etc/nginx/templates/default.conf.template

EXPOSE 80