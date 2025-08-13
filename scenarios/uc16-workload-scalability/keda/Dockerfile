FROM php:8.2-ubi8

USER root
RUN yum install -y php-pecl-redis && yum clean all
USER 1001 