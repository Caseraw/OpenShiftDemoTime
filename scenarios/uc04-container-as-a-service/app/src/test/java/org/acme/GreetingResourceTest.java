package org.acme;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@QuarkusTest
class GreetingResourceTest {

     @ConfigProperty(name = "BUILD")
    String build;

    @Test
    void testHelloEndpoint() {
        given()
          .when().get("/hello")
          .then()
             .statusCode(200)
             .body(is("Hello World, container image from [ " + build + " ]"));
    }

}