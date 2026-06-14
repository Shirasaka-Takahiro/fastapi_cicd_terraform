FROM python:3.8-alpine

ENV PYTHONUNBUFFERED=1

#ドキュメントルート作成
RUN mkdir -p /var/www/vhosts/www.quick-infra.net.conf/public_html

WORKDIR /var/www/vhosts/www.quick-infra.net.conf/public_html

#COPY ./app/src .
COPY ./src .

# コンテナイメージ内で必要なパッケージをインストール
RUN apk add --no-cache vim less build-base && \
    pip install --upgrade pip --no-cache-dir --trusted-host pypi.python.org -r requirements.txt && \
    apk del build-base

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]