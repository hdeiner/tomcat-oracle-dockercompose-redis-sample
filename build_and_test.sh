#!/usr/bin/env bash

echo "Start the redis server"
docker-compose -f compose-redis.yml -p redis-oracle-tomcat up -d

# this needs to be replaced with looking at the docker logs for redis
echo "Waiting for redis to start"
sleep 15

echo "Bring up Oracle"
docker-compose -f compose-oracle.yml -p redis-oracle-tomcat up -d

# this needs to be replaced with looking at the docker logs for oracle
echo "Waiting for Oracle to start"
sleep 30

# there is obvious dupication in the oracle url, username, and password that should
# be refactored - this is an example only
# for references to things running on this machine, you will see a lot of $(hostname)
# for references from the Tomcat container to the Oracle container, you will see oracle.  When the comtainers are on different machines, a DNS reference will be needed.
echo "Setup configurations in redis"

redis-cli -h $(hostname) set LiquibaseDriver "driver: oracle.jdbc.driver.OracleDriver"
redis-cli -h $(hostname) set LiquibaseClasspath "classpath: lib/ojdbc8.jar"
redis-cli -h $(hostname) set LiquibaseOracleURL "url: jdbc:oracle:thin:@"$(hostname)":1521:xe"
redis-cli -h $(hostname) set LiquibaseOracleDatabaseUsername "username: system"
redis-cli -h $(hostname) set LiquibaseOracleDatabasePassword "password: oracle"

redis-cli -h $(hostname) set OracaleConfigURL "url=jdbc:oracle:thin:@"oracle":1521/xe"
redis-cli -h $(hostname) set OraclConfigUser "user=system"
redis-cli -h $(hostname) set OracleConfigPassword "password=oracle"

redis-cli -h $(hostname) set TomcatURL "hosturl=http://"$(hostname)":8080"

echo "Build the liquibase.properties file for Liquibase to run against"
redis-cli -h $(hostname) get LiquibaseDriver > liquibase.properties
redis-cli -h $(hostname) get LiquibaseClasspath >> liquibase.properties
redis-cli -h $(hostname) get LiquibaseOracleURL >> liquibase.properties
redis-cli -h $(hostname) get LiquibaseOracleDatabaseUsername >> liquibase.properties
redis-cli -h $(hostname) get LiquibaseOracleDatabasePassword >> liquibase.properties

echo "Create database schema and load sample data"
liquibase --changeLogFile=src/main/db/changelog.xml update

echo "Build fresh war for Tomcat deployment"
mvn clean compile war:war

echo "Build the oracleConfig.properties file for the Tomcat application under test"
redis-cli -h $(hostname) get OracaleConfigURL > oracleConfig.properties
redis-cli -h $(hostname) get OraclConfigUser >> oracleConfig.properties
redis-cli -h $(hostname) get OracleConfigPassword >> oracleConfig.properties

echo "Configuring war to point to Oracle endpoint"
cp oracleConfig.properties target/

# this needs to be replaced with looking at the docker logs for tomcat
echo "Bring up Tomcat"
docker-compose -f compose-tomcat.yml -p redis-oracle-tomcat up -d

echo "Waiting for Tomcat to start"
sleep 120

echo Smoke test
curl -s http://$(hostname):8080/passwordAPI/passwordDB > temp
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