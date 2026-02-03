import gleam/http
import gleam/list
import gleam/option
import gleam/result
import gleeunit/should
import stytch/data
import stytch/transport
import wisp/simulate

fn sample_user() -> data.User {
  data.User(
    user_id: "user-test-123",
    name: data.UserName(
      first_name: option.Some("Test"),
      middle_name: option.None,
      last_name: option.Some("User"),
    ),
    emails: [
      data.Email(
        email_id: "email-test-123",
        email: "user@example.com",
        verified: True,
      ),
    ],
    phone_numbers: [],
    providers: [],
    webauthn_registrations: [],
    biometric_registrations: [],
    totps: [],
    password: option.None,
    roles: ["stytch_user"],
    created_at: "2026-01-05T23:58:08Z",
    status: data.Active,
  )
}

pub fn user_dashboard_response_happy_path_test() {
  let req = simulate.request(http.Get, "/")
  let response =
    transport.user_dashboard_response(
      Ok(#(sample_user(), "session-jwt-test-123")),
      req,
    )

  should.equal(response.status, 200)
  should.not_equal(simulate.read_body(response), "")
  should.be_true(
    response.headers
    |> list.key_find("set-cookie")
    |> result.is_ok,
  )
}

pub fn user_dashboard_response_error_test() {
  let req = simulate.request(http.Get, "/")
  let response = transport.user_dashboard_response(Error("boom"), req)

  should.equal(response.status, 400)
  should.not_equal(simulate.read_body(response), "")
}
