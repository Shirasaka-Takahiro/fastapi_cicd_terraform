FROM nginx:1.25.0

#confファイルのコピー
COPY ./web/conf/www.example.com.conf /etc/nginx/conf.d

#ドキュメントルート作成
RUN mkdir -p /var/www/vhosts/www.example.com.conf/public_html

EXPOSE 80