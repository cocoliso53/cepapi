import gleam/http/response
import gleam/json
import gleeunit/should
import stytch/codec
import stytch/data
import stytch/service

fn auth_response_json() -> String {
  "{\"status_code\":200,\"request_id\":\"request-id-test-123\",\"session_token\":\"session-token-test-123\",\"session_jwt\":\"session-jwt-test-123\",\"user\":{\"user_id\":\"user-test-123\",\"name\":{\"first_name\":\"Test\",\"middle_name\":null,\"last_name\":\"User\"},\"emails\":[{\"email\":\"user@example.com\",\"email_id\":\"email-test-123\",\"verified\":true}],\"phone_numbers\":[],\"providers\":[{\"locale\":\"\",\"oauth_user_registration_id\":\"oauth-user-test-123\",\"profile_picture_url\":\"https://example.com/avatar.png\",\"provider_subject\":\"subject-123\",\"provider_type\":\"Google\"}],\"roles\":[\"stytch_user\"],\"status\":\"active\",\"created_at\":\"2026-01-05T23:58:08Z\",\"webauthn_registrations\":[],\"biometric_registrations\":[],\"totps\":[],\"password\":null}}"
}

fn expected_user_and_token() -> #(data.User, data.SessionJWT) {
  let assert Ok(parsed) =
    auth_response_json()
    |> json.parse(codec.auth_response_decoder())

  #(parsed.user, parsed.session_jwt)
}

pub fn get_user_and_token_happy_path_test() {
  let response =
    response.new(200)
    |> response.set_body(auth_response_json())

  should.equal(
    service.get_user_and_token(Ok(response)),
    Ok(expected_user_and_token()),
  )
}

pub fn get_user_and_token_invalid_json_test() {
  let response = response.new(200) |> response.set_body("{")

  should.be_error(service.get_user_and_token(Ok(response)))
}

pub fn get_user_and_token_client_error_test() {
  should.equal(
    service.get_user_and_token(Error(data.ElseError("boom"))),
    Error("error"),
  )
}
