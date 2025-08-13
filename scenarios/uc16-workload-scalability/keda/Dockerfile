#FROM php:8.2-ubi8

from image-registry.openshift-image-registry.svc:5000/openshift/php@sha256:dcf48a3da2fbef31ed39202517c8b0580ff4aa12f78bb0e02a95a3db77ffa9f3

USER root
RUN yum install -y php-pecl-redis && yum clean all
USER 1001 