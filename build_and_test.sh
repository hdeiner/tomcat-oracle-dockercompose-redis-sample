#!/usr/bin/env bash

echo "Start the redis server"
docker-compose -f compose-redis.yml -p redis-oracle-tomcat up -d

echo "Waiting for redis to start"
sleep 15

echo "Bring up Oracle"
docker-compose -f compose-oracle.yml -p redis-oracle-tomcat up -d

echo "Waiting for Oracle to start"
sleep 30

# there is obvious dupication in the oracle url, username, and password that should
# be refactored - this is an example only
echo "Setup configurations in redis"

redis-cli set LiquibaseDriver "driver: oracle.jdbc.driver.OracleDriver"
redis-cli set LiquibaseClasspath "classpath: lib/ojdbc8.jar"
redis-cli set LiquibaseOracleURL "url: jdbc:oracle:thin:@"$(hostname)":1521:xe"
redis-cli set LiquibaseOracleDatabaseUsername "username: system"
redis-cli set LiquibaseOracleDatabasePassword "password: oracle"

redis-cli set OracaleConfigURL "url=jdbc:oracle:thin:@"$(hostname)":1521/xe"
redis-cli set OraclConfigUser "user=system"
redis-cli set OracleConfigPassword "password=oracle"

redis-cli set TomcatURL "hosturl=http://"$(hostname)":8080"

echo "Build the liquibase.properties file for Liquibase to run against"
redis-cli get LiquibaseDriver > liquibase.properties
redis-cli get LiquibaseClasspath >> liquibase.properties
redis-cli get LiquibaseOracleURL >> liquibase.properties
redis-cli get LiquibaseOracleDatabaseUsername >> liquibase.properties
redis-cli get LiquibaseOracleDatabasePassword >> liquibase.properties

echo "Create database schema and load sample data"
liquibase --changeLogFile=src/main/db/changelog.xml update

echo "Build fresh war for Tomcat deployment"
mvn clean compile war:war

echo "Build the oracleConfig.properties file for the Tomcat application under test"
redis-cli get OracaleConfigURL > oracleConfig.properties
redis-cli get OraclConfigUser >> oracleConfig.properties
redis-cli get OracleConfigPassword >> oracleConfig.properties

echo "Configuring war to point to Oracle endpoint"
cp oracleConfig.properties target/

echo "Bring up Tomcat"
docker-compose -f compose-tomcat.yml -p redis-oracle-tomcat up -d

echo "Waiting for Tomcat to start"
sleep 120

echo Smoke test
curl -s http://localhost:8080/passwordAPI/passwordDB > temp
if grep -q "RESULT_SET" temp
then
    echo "SMOKE TEST SUCCESS"
else
    echo "SMOKE TEST FAILURE!!!"
fi
rm temp

echo "Configuring test application to point to Tomcat endpoint"
redis-cli get TomcatURL > rest_webservice.properties

echo "Run integration tests"
mvn verify failsafe:integration-test

echo "Bring down Tomcat, Oracle, and Redis"
docker-compose -f compose-tomcat.yml -p redis-oracle-tomcat down
docker-compose -f compose-oracle.yml -p redis-oracle-tomcat down
docker-compose -f compose-redis.yml -p redis-oracle-tomcat down