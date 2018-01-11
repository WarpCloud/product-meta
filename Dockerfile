FROM 172.16.1.41:5000/release/basefs:latest

MAINTAINER xiaming.chen@transwarp.io

WORKDIR /root/product-meta

COPY . .

RUN ls -l
