package main;

public class PasswordStrength {
    String password = null;

    public PasswordStrength(String password) {
        this.password = password;
    }

    public int evaluate() {
        int strength = 0;
        strength = password.length() - 8;
        String previousCharacter = " ";
        for (int i=0; i<password.length(); i++) {
            String character = password.substring(i,i+1);
            if (character.matches("[\\!\\@\\#\\$\\%\\^\\&\\*\\(\\)0-9]")) strength++;
            if ((previousCharacter.matches("[A-Z]"))&&(character.matches("[A-Z]"))) {
                strength--;
            }
            if ((previousCharacter.matches("[a-z]"))&&(character.matches("[a-z]"))) {
                strength--;
            }
            if ((previousCharacter.matches("[\\!\\@\\#\\$\\%\\^\\&\\*\\(\\)]"))&&(character.matches("[\\!\\@\\#\\$\\%\\^\\&\\*\\(\\)]"))) {
                strength--;
            }
            if ((previousCharacter.matches("[0-9]"))&&(character.matches("[0-9]"))) {
                strength--;
            }
            previousCharacter = character;
        }
        return strength;
    }
}
