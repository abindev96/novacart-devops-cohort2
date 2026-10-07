FROM nginxinc/nginx-unprivileged:1.27-alpine

USER root

COPY index.html app.js styles.css /usr/share/nginx/html/

COPY docker/nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY docker/entrypoint.sh /usr/local/bin/novacart-entrypoint.sh

RUN chmod +x /usr/local/bin/novacart-entrypoint.sh

EXPOSE 8080

USER 101

ENTRYPOINT ["/usr/local/bin/novacart-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]