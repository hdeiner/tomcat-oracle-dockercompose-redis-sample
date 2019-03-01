#!/usr/bin/env bash

figlet -f standard "Instanciate and Provision Redis"

echo "Start the redis server"
docker-compose -f compose-redis.yml -p redis-oracle-tomcat up -d

echo "Waiting for Redis to start"
while true ; do
  result=$(docker logs redis 2> /dev/null | grep -c "Ready to accept connections")
  if [ $result = 1 ] ; then
    echo "Redis has started"
    break
  fi
  sleep 1
done

figlet -f standard "Instanciate and Provision Oracle"

echo "Bring up Oracle"
docker-compose -f compose-oracle.yml -p redis-oracle-tomcat up -d

echo "Waiting for Oracle to start"
while true ; do
  curl -s localhost:8081 > tmp.txt
  result=$(grep -c "DOCTYPE HTML PUBLIC" tmp.txt)
  if [ $result = 1 ] ; then
    echo "Oracle has started"
    break
  fi
  sleep 1
done
rm tmp.txt

figlet -f standard "Configure for Oracle in Redis"

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

figlet -f standard "Create Oracle Database"

echo "Build the liquibase.properties file for Liquibase to run against"
redis-cli -h $(hostname) get LiquibaseDriver > liquibase.properties
redis-cli -h $(hostname) get LiquibaseClasspath >> liquibase.properties
redis-cli -h $(hostname) get LiquibaseOracleURL >> liquibase.properties
redis-cli -h $(hostname) get LiquibaseOracleDatabaseUsername >> liquibase.properties
redis-cli -h $(hostname) get LiquibaseOracleDatabasePassword >> liquibase.properties

echo "Create database schema and load sample data"
liquibase --changeLogFile=src/main/db/changelog.xml update

figlet -f standard "Instanciate and Provision Tomcat"

echo "Build fresh war for Tomcat deployment"
mvn -q clean compile war:war

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
while true ; do
  curl -s localhost:8080 > tmp.txt
  result=$(grep -c "HTTP Status 404" tmp.txt)
  if [ $result = 1 ] ; then
    echo "Tomcat has started"
    break
  fi
  sleep 1
done
rm tmp.txt

figlet -f standard "Run Tests"

echo Smoke test
curl -s http://$(hostname):8080/passwordAPI/passwordDB > temp
if grep -q "RESULT_SET" temp
then
    echo "SMOKE TEST SUCCESS"
    figlet -f slant "Smoke Test Success"

    echo "Configuring test application to point to Tomcat endpoint"
    redis-cli get TomcatURL > rest_webservice.properties

    echo "Run integration tests"
    mvn -q verify failsafe:integration-test
else
    echo "SMOKE TEST FAILURE!!!"
    figlet -f slant "Smoke Test Failure"
fi
rm temp

figlet -f standard "Teardown Everything"

echo "Bring down Tomcat, Oracle, and Redis"
docker-compose -f compose-tomcat.yml -p redis-oracle-tomcat down
docker-compose -f compose-oracle.yml -p redis-oracle-tomcat down
docker-compose -f compose-redis.yml -p redis-oracle-tomcat down

rm liquibase.properties oracleConfig.properties rest_webservice.properties