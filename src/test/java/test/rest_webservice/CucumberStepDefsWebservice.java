package test.rest_webservice;

import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.MatcherAssert.assertThat;

public class CucumberStepDefsWebservice {
    private static CucumberClientInterface cucumberClientInterface;

    private String password;

    @Given("^I want to change my password with the UM Portal$")
    public void i_want_to_change_my_password_with_the_UM_Portal() {
        cucumberClientInterface = new CucumberClientWebservice();
    }

    @When("^I try to set my new password to \"([^\"]*)\"$")
    public void i_try_to_set_my_new_password_to(String password) {
        this.password = password;
    }

    @Then("^I then I should be told \"([^\"]*)\"$")
    public void i_then_I_should_be_told(String passwordAdvice) {
        assertThat(cucumberClientInterface.getPasswordRules(password), is(passwordAdvice));
    }

    @Then("^I then I should be told that it has a strength of \"([^\"]*)\"$")
    public void i_then_I_should_be_told_that_it_has_a_strength_of(String passwordStrength) {
        assertThat(cucumberClientInterface.getPasswordStrength(password), is(passwordStrength));
    }

}