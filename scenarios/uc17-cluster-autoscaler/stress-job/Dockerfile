FROM registry.redhat.io/ubi9:latest

USER 0

RUN subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms &&\
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm &&\
    dnf install -y stress && \
    dnf clean all

USER 1001

COPY app.sh /app.sh
RUN chmod +x /app.sh

CMD ["/app.sh"]
