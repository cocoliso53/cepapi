import gleam/dynamic
import gleam/dynamic/decode
import gleam/option
import gleeunit/should
import stytch/codec
import stytch/data

fn sample_user_dynamic() -> dynamic.Dynamic {
  dynamic.properties([
    #(dynamic.string("user_id"), dynamic.string("user-test-123")),
    #(
      dynamic.string("name"),
      dynamic.properties([
        #(dynamic.string("first_name"), dynamic.string("Ada")),
        #(dynamic.string("middle_name"), dynamic.nil()),
        #(dynamic.string("last_name"), dynamic.string("Lovelace")),
      ]),
    ),
    #(
      dynamic.string("emails"),
      dynamic.list([
        dynamic.properties([
          #(dynamic.string("email_id"), dynamic.string("email-test-123")),
          #(dynamic.string("email"), dynamic.string("ada@example.com")),
          #(dynamic.string("verified"), dynamic.bool(True)),
        ]),
      ]),
    ),
    #(dynamic.string("phone_numbers"), dynamic.list([])),
    #(
      dynamic.string("providers"),
      dynamic.list([
        dynamic.properties([
          #(
            dynamic.string("oauth_user_registration_id"),
            dynamic.string("oauth-user-test-123"),
          ),
          #(dynamic.string("provider_subject"), dynamic.string("subject-123")),
          #(dynamic.string("provider_type"), dynamic.string("Google")),
          #(
            dynamic.string("profile_picture_url"),
            dynamic.string("https://example.com/avatar.png"),
          ),
          #(dynamic.string("locale"), dynamic.string("")),
        ]),
      ]),
    ),
    #(dynamic.string("webauthn_registrations"), dynamic.list([])),
    #(dynamic.string("biometric_registrations"), dynamic.list([])),
    #(dynamic.string("totps"), dynamic.list([])),
    #(dynamic.string("password"), dynamic.nil()),
    #(
      dynamic.string("roles"),
      dynamic.list([dynamic.string("stytch_user")]),
    ),
    #(dynamic.string("created_at"), dynamic.string("2026-01-05T23:58:08Z")),
    #(dynamic.string("status"), dynamic.string("active")),
  ])
}

fn sample_user_data() -> data.User {
  data.User(
    user_id: "user-test-123",
    name: data.UserName(
      first_name: option.Some("Ada"),
      middle_name: option.None,
      last_name: option.Some("Lovelace"),
    ),
    emails: [
      data.Email(
        email_id: "email-test-123",
        email: "ada@example.com",
        verified: True,
      ),
    ],
    phone_numbers: [],
    providers: [
      data.Provider(
        oauth_user_registration_id: "oauth-user-test-123",
        provider_subject: "subject-123",
        provider_type: "Google",
        profile_picture_url: "https://example.com/avatar.png",
        locale: "",
      ),
    ],
    webauthn_registrations: [],
    biometric_registrations: [],
    totps: [],
    password: option.None,
    roles: ["stytch_user"],
    created_at: "2026-01-05T23:58:08Z",
    status: data.Active,
  )
}

pub fn auth_response_decoder_happy_path_test() {
  let response_dyn =
    dynamic.properties([
      #(dynamic.string("status_code"), dynamic.int(200)),
      #(dynamic.string("request_id"), dynamic.string("request-id-123123")),
      #(dynamic.string("user"), sample_user_dynamic()),
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
      user: sample_user_data(),
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
      #(dynamic.string("user"), sample_user_dynamic()),
      #(dynamic.string("session_token"), dynamic.string("session-token-123abc")),
      #(dynamic.string("session_jwt"), dynamic.string("session-jwt-abc-123")),
    ])

  should.be_error(decode.run(response_dyn, codec.auth_response_decoder()))
}

pub fn user_decoder_happy_path_test() {
  should.equal(
    decode.run(sample_user_dynamic(), codec.user_decoder()),
    Ok(sample_user_data()),
  )
}

pub fn status_decoder_invalid_value_test() {
  let response_dyn = dynamic.string("unknown")

  should.be_error(decode.run(response_dyn, codec.status_decoder()))
}
