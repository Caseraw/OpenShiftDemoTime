FROM registry.redhat.io/ubi9:latest

USER 0
RUN curl -o /etc/yum.repos.d/epel.repo https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    rpm -ivh /etc/yum.repos.d/epel-release-latest-9.noarch.rpm && \
    dnf install -y stress && \
    dnf clean all

USER 1001

COPY app.sh /app.sh
RUN chmod +x /app.sh

CMD ["/app.sh"]
