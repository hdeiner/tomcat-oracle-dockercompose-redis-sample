package test.rest_webservice;

import us.monoid.json.JSONException;
import us.monoid.web.JSONResource;
import us.monoid.web.Resty;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Properties;

import static us.monoid.web.Resty.content;

public class CucumberClientWebservice implements CucumberClientInterface {

    public String getPasswordRules(String password){
        String words = "";
        Resty resty  = new Resty();

        URL url = null;
        URI uri;

        Properties prop = new Properties();
        InputStream input = null;

        try {
            input = new FileInputStream("rest_webservice.properties");
            prop.load(input);
            String hosturl = prop.getProperty("hosturl");

            url = new URL(hosturl + "/passwordAPI/passwordRules/"+password);
            uri = new URI(url.getProtocol(), url.getUserInfo(), url.getHost(), url.getPort(), url.getPath(), url.getQuery(), url.getRef());
            JSONResource response = resty.json(uri);
            words = (String) response.get("passwordRules");
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (URISyntaxException e) {
            e.printStackTrace();
        } catch (JSONException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return words;
    }

    public String getPasswordStrength(String password){
        String words = "";
        Resty resty  = new Resty();

        URL url = null;
        URI uri;

        Properties prop = new Properties();
        InputStream input = null;

        try {
            input = new FileInputStream("rest_webservice.properties");
            prop.load(input);
            String hosturl = prop.getProperty("hosturl");

            url = new URL(hosturl + "/passwordAPI/passwordStrength/"+password);
            uri = new URI(url.getProtocol(), url.getUserInfo(), url.getHost(), url.getPort(), url.getPath(), url.getQuery(), url.getRef());
            JSONResource response = resty.json(uri);
            words = (String) response.get("passwordStrength");
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (URISyntaxException e) {
            e.printStackTrace();
        } catch (JSONException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return words;
    }
}