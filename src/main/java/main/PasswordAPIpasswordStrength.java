package main;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/passwordStrength")
public class PasswordAPIpasswordStrength {

    @GET
    @Path("{password}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response passwordStrength(@PathParam("password") String password) {
        return Response.status(200).entity(jsonResponse(password)).build();
    }

    private String jsonResponse(String password) {
        return "{\"password\": \"" + password + "\"," +
                "\"passwordStrength\":\"" + new PasswordStrength(password).evaluate() + "\"}";
    }
}