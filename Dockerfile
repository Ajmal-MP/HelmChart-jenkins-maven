FROM tomcat

LABEL maintainer=ajmal

ADD  ./target/maven-sample.war /usr/local/tomcat/webapps/

EXPOSE 8080

CMD ["catalina.sh","run"]
