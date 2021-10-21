package se.yolean.quarkustest.javet;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import com.caoccao.javet.exceptions.JavetException;
import com.caoccao.javet.interop.V8Host;
import com.caoccao.javet.interop.V8Runtime;

@Path("/javet/node")
public class JavetNodeResource {

    @GET
    @Path("/hello")
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
      try (V8Runtime v8Runtime = V8Host.getNodeInstance().createV8Runtime()) {
        return v8Runtime.getExecutor("'Hello Javet Node\\n'").executeString();
      } catch (JavetException e) {
        throw new RuntimeException("TODO handle error", e);
      }
    }
}