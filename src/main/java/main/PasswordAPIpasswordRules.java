package main;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/passwordRules")
public class PasswordAPIpasswordRules {

    @GET
    @Path("{password}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response passwordRules(@PathParam("password") String password) {
        return Response.status(200).entity(jsonResponse(password)).build();
    }

    private String jsonResponse(String password) {
        return "{\"password\": \"" + password + "\"," +
                "\"passwordRules\":\"" + new PasswordRules(password).evaluate() + "\"}";
    }
}