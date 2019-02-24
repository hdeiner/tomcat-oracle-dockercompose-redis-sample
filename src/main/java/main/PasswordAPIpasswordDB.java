package main;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/passwordDB")
public class PasswordAPIpasswordDB {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Response passwordDB() {
        return Response.status(200).entity(jsonResponse()).build();
    }

    private String jsonResponse() {
        return "{" + new PasswordDB().evaluate() + "}";
    }
}
