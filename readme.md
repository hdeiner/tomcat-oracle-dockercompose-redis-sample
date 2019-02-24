This project demonstrates a way to build and test locally between an Oracle database and a Tomcat application incorporating Redis to hold configuration information.

We add the complexity of how to distribute secrets and configuration to the deployed application as well. 

This project explores a "halfway" solution to configuration of endpoints and configuration in general.  We could redesign our applications to make redis querries as they run to get what they need.  However, many applications already use "property" files.  We will build the property files from redis-cli queries, construct the property files, and put them into the containers which are calling upon them.  Again, this is not THE solution, but an easy to follow example to get you started thinking about how redis can be used.

```bash
./build_and_test.sh
```
1. Bring up a redis server.  We are running in a container locally, but the container can run anywhere.
2. Bring up an Oracle database.  We are running in a container locally, but the container can run anywhere.
3. Send off all sorts of configuraion information to the redis server.
4. Construct a properties file for running Liquibase to establish the database from redis information and then run Liquibase.
5. Compile the war for Tomcat to run.  
6. Construct a properties file for configuring the war to run on Tomcat (it says where the database is and gives connection information).  Deploy it (by copy) to the war. 
7. Run a smoke test to make sure everything is wired together correctly.
8. Construct a configuration file to point the test program to the web service to test.
9. Run the test program (a Cucumber regression test).
10. Tear down the containers we put together.

The next step is to deploy the containers on AWS through Terraform'ed infrastructure.  Each AWS EC2 instance will run Docker and we will simply deploy the containers to them using DockerHub to hold the images we create from the containers.