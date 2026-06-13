FROM python:3.8-alpine

#ドキュメントルート作成
RUN mkdir -p /var/www/vhosts/www.example.com.conf/public_html

WORKDIR /var/www/vhosts/www.example.com.conf/public_html

COPY ./app/src .

# コンテナイメージ内で必要なパッケージをインストール
RUN apk add --no-cache vim less build-base && \
    pip install --upgrade pip --no-cache-dir --trusted-host pypi.python.org -r requirements.txt && \
    apk del build-base

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]