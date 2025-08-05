FROM registry.access.redhat.com/ubi9/openjdk-21:1.21

ENV LANGUAGE='en_US:en'


#COPY target/lib/* /deployments/lib/
COPY jar/app.jar /app.jar

EXPOSE 8080
USER 185
ENV JAVA_OPTS_APPEND="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
ENV JAVA_APP_JAR="/deployments/app.jar"

ENTRYPOINT [ "/opt/jboss/container/java/run/run-java.sh" ]
