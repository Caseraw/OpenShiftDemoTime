FROM fedora:latest

RUN dnf install -y stress && dnf clean all

COPY app.sh /app.sh
RUN chmod +x /app.sh

CMD ["/app.sh"]
