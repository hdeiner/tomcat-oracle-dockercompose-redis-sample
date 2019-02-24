package main;

public class PasswordRules {
    String password = null;

    public PasswordRules(String password) {
        this.password = password;
    }

    public String evaluate() {
        if (!password.matches(".*[A-Za-z]+.*")) {
            return "password must have letters in it";
        }
        if (password.length() < 8) {
            return "password must be at least 8 characters long";
        }
        if (password.matches(".*[ ]+.*")) {
            return "password can not have any spaces in it";
        }
        if (!(password.matches(".*[A-Z]+.*")&&(password.matches(".*[a-z]+.*")))) {
            return "password must have both upper and lower case letters in it";
        }
        if (!(password.matches(".*[0-9]+.*"))) {
            return "password must have at least 1 digit in it";
        }
        if (!(password.matches(".*[\\!\\@\\#\\$\\%\\^\\&\\*\\(\\)]+.*"))) {
            return "password must have at least 1 special case character in it";
        }
        return "password OK";
    }
}