FROM nginx:latest

#confファイルのコピー
#COPY ./web/conf/www.quick-infra.net.conf /etc/nginx/conf.d
COPY ./conf/www.quick-infra.net.conf /etc/nginx/conf.d

#ドキュメントルート作成
RUN mkdir -p /var/www/vhosts/www.quick-infra.net/public_html

EXPOSE 80