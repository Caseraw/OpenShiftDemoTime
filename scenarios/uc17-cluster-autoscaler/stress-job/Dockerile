FROM registry.redhat.io/ubi9-minimal:latest

USER 0
RUN dnf install -y epel-release && \
    dnf install -y stress && \
    dnf clean all
USER 1001

COPY app.sh /app.sh
RUN chmod +x /app.sh

CMD ["/app.sh"]
