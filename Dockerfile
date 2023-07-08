FROM adoptopenjdk/maven-openjdk11:alpine-jre

ARG artifact=target/coffeeshop-site.jar

WORKDIR /opt/app 

COPY ${artifact} app.jar

ENTRYPOINT [ "java", "-jar","app.jar" ]
