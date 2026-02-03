import envoy
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleeunit/should
import stytch/client
import stytch/data

pub fn stytch_token_auth_happy_path_test() {
  envoy.set("AUTH_TOKEN", "basic-token")

  let send_fn = fn(req: request.Request(String)) {
    let request.Request(method: method, host: host, path: path, body: body, ..) =
      req

    should.equal(method, http.Post)
    // This one we might need to remove or update later on 
    should.equal(host, "test.stytch.com")
    should.equal(path, "/v1/oauth/authenticate")
    should.equal(
      request.get_header(req, "content-type"),
      Ok("application/json"),
    )
    should.equal(
      request.get_header(req, "authorization"),
      Ok("Basic basic-token"),
    )
    should.equal(
      body,
      "{\"token\":\"token-123\",\"session_duration_minutes\":60}",
    )

    Ok(response.new(200) |> response.set_body("ok"))
  }

  should.equal(
    client.stytch_token_auth(send_fn, "token-123"),
    Ok(response.new(200) |> response.set_body("ok")),
  )
}

pub fn stytch_token_auth_send_error_test() {
  envoy.set("AUTH_TOKEN", "basic-token")

  let send_fn = fn(_req: request.Request(String)) {
    Error(httpc.InvalidUtf8Response)
  }

  should.equal(
    client.stytch_token_auth(send_fn, "token-123"),
    Error(data.HttpError(httpc.InvalidUtf8Response)),
  )
}
