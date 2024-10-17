FROM ubuntu:22.04

RUN apt update \
    && apt upgrade \
    && apt install -y mysql-server-5.7


ENV MYSQL_ROOT_PASSWORD=123456
ENV MYSQL_DATABASE=wordpress
ENV MYSQL_USER=andy
ENV MYSQL_PASSWORD=a30812

# 复制初始化脚本到容器内并执行
COPY ./init.sh /docker-entrypoint-initdb.d/init.sh