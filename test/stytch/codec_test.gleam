import gleam/dynamic
import gleam/dynamic/decode
import gleeunit/should
import stytch/codec
import stytch/data

pub fn auth_response_decoder_happy_path_test() {
  let response_dyn =
    dynamic.properties([
      #(dynamic.string("status_code"), dynamic.int(200)),
      #(dynamic.string("request_id"), dynamic.string("request-id-123123")),
      #(dynamic.string("session_token"), dynamic.string("session-token-123abc")),
      #(dynamic.string("session_jwt"), dynamic.string("session-jwt-abc-123")),
      // Extra key-value pair will not get parsed 
      #(dynamic.string("extra_field"), dynamic.string("extra-data")),
    ])

  should.equal(
    decode.run(response_dyn, codec.auth_response_decoder()),
    Ok(data.AuthResponse(
      status_code: 200,
      request_id: "request-id-123123",
      session_token: "session-token-123abc",
      session_jwt: "session-jwt-abc-123",
    )),
  )
}

pub fn auth_response_decoder_missing_fields_test() {
  let response_dyn =
    dynamic.properties([
      #(dynamic.string("status_code"), dynamic.int(200)),
      #(dynamic.string("request_id"), dynamic.string("request-id-123123")),
      #(dynamic.string("session_token"), dynamic.string("session-token-123abc")),
    ])

  should.be_error(decode.run(response_dyn, codec.auth_response_decoder()))
}

pub fn auth_response_decoder_wrong_type_test() {
  let response_dyn =
    dynamic.properties([
      #(dynamic.string("status_code"), dynamic.string("200")),
      #(dynamic.string("request_id"), dynamic.string("request-id-123123")),
      #(dynamic.string("session_token"), dynamic.string("session-token-123abc")),
      #(dynamic.string("session_jwt"), dynamic.string("session-jwt-abc-123")),
    ])

  should.be_error(decode.run(response_dyn, codec.auth_response_decoder()))
}
