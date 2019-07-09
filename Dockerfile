FROM 172.16.1.99/transwarp/alpine:transwarp-base

MAINTAINER xiaming.chen@transwarp.io

WORKDIR /root/product-meta

COPY . .

RUN ls -l
