package test.rest_webservice;

interface CucumberClientInterface {
    String getPasswordRules(String password);
    String getPasswordStrength(String password);
}