Feature: UM Portal API - Password Strength

  As a security officer,
  I want to ensure that users choose passwords that are hard to reproduce,
  So that passwords aren't easily compromised.

  Password strength is calculated by the following formula
  1. Take the length of the password and subtract 8
  2. Add in all special special characters used in the password
  3. Subtract all consecutive upper or lower or special character or digit sequences in the password

  Scenario Outline: Password strength metric
    Given I want to change my password with the UM Portal
    When I try to set my new password to "<password>"
    Then I then I should be told that it has a strength of "<passwordStrength>"

    Examples:
      | password                   | passwordStrength |
      | passWord1!                 | -1               |
      | bFihJv!srBChibW4ay*eXEksdh | 11               |