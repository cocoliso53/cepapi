import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/option
import gleam/string
import stytch/data

pub fn decode_error_to_string(error: decode.DecodeError) -> String {
  "Decode error. Expected: "
  <> error.expected
  <> " Found: "
  <> error.found
  <> " Path: "
  <> string.join(error.path, ", ")
}

pub fn user_name_decoder() -> decode.Decoder(data.UserName) {
  use first_name <- decode.field("first_name", decode.optional(decode.string))
  use middle_name <- decode.field("middle_name", decode.optional(decode.string))
  use last_name <- decode.field("last_name", decode.optional(decode.string))
  decode.success(data.UserName(first_name:, middle_name:, last_name:))
}

pub fn email_decoder() -> decode.Decoder(data.Email) {
  use email_id <- decode.field("email_id", decode.string)
  use email <- decode.field("email", decode.string)
  use verified <- decode.field("verified", decode.bool)
  decode.success(data.Email(email_id:, email:, verified:))
}

pub fn phone_number_decoder() -> decode.Decoder(data.PhoneNumber) {
  use phone_id <- decode.field("phone_id", decode.string)
  use phone_number <- decode.field("phone_number", decode.string)
  use verified <- decode.field("verified", decode.bool)
  decode.success(data.PhoneNumber(phone_id:, phone_number:, verified:))
}

pub fn provider_decoder() -> decode.Decoder(data.Provider) {
  use oauth_user_registration_id <- decode.field(
    "oauth_user_registration_id",
    decode.string,
  )
  use provider_subject <- decode.field("provider_subject", decode.string)
  use provider_type <- decode.field("provider_type", decode.string)
  use profile_picture_url <- decode.field("profile_picture_url", decode.string)
  use locale <- decode.field("locale", decode.string)
  decode.success(data.Provider(
    oauth_user_registration_id:,
    provider_subject:,
    provider_type:,
    profile_picture_url:,
    locale:,
  ))
}

pub fn webauthn_registration_decoder() -> decode.Decoder(
  data.WebauthnRegistration,
) {
  use webauthn_registration_id <- decode.field(
    "webauthn_registration_id",
    decode.string,
  )
  use domain <- decode.field("domain", decode.string)
  use user_agent <- decode.field("user_agent", decode.string)
  use authenticator_type <- decode.field("authenticator_type", decode.string)
  use verified <- decode.field("verified", decode.bool)
  use name <- decode.field("name", decode.string)
  decode.success(data.WebauthnRegistration(
    webauthn_registration_id:,
    domain:,
    user_agent:,
    authenticator_type:,
    verified:,
    name:,
  ))
}

pub fn biometric_registration_decoder() -> decode.Decoder(
  data.BiometricRegistration,
) {
  use biometric_registration_id <- decode.field(
    "biometric_registration_id",
    decode.string,
  )
  use verified <- decode.field("verified", decode.bool)
  decode.success(data.BiometricRegistration(
    biometric_registration_id:,
    verified:,
  ))
}

pub fn totp_decoder() -> decode.Decoder(data.Totp) {
  use totp_id <- decode.field("totp_id", decode.string)
  use verified <- decode.field("verified", decode.bool)
  decode.success(data.Totp(totp_id:, verified:))
}

pub fn crypto_wallet_decoder() -> decode.Decoder(data.CryptoWallet) {
  use crypto_wallet_id <- decode.field("crypto_wallet_id", decode.string)
  use crypto_wallet_address <- decode.field(
    "crypto_wallet_address",
    decode.string,
  )
  use crypto_wallet_type <- decode.field("crypto_wallet_type", decode.string)
  use verified <- decode.field("verified", decode.bool)
  decode.success(data.CryptoWallet(
    crypto_wallet_id:,
    crypto_wallet_address:,
    crypto_wallet_type:,
    verified:,
  ))
}

pub fn password_decoder() -> decode.Decoder(data.Password) {
  use password_id <- decode.field("password_id", decode.string)
  use requires_reset <- decode.field("requires_reset", decode.bool)
  decode.success(data.Password(password_id:, requires_reset:))
}

pub fn status_decoder() -> decode.Decoder(data.Status) {
  decode.string
  |> decode.then(fn(value) {
    case string.lowercase(value) {
      "pending" -> decode.success(data.Pending)
      "active" -> decode.success(data.Active)
      _ -> decode.failure(data.Active, expected: "Status")
    }
  })
}

pub fn user_decoder() -> decode.Decoder(data.User) {
  use user_id <- decode.field("user_id", decode.string)
  use name <- decode.field("name", user_name_decoder())
  use emails <- decode.field("emails", decode.list(email_decoder()))
  use phone_numbers <- decode.field(
    "phone_numbers",
    decode.list(phone_number_decoder()),
  )
  use providers <- decode.field("providers", decode.list(provider_decoder()))
  use webauthn_registrations <- decode.field(
    "webauthn_registrations",
    decode.list(webauthn_registration_decoder()),
  )
  use biometric_registrations <- decode.field(
    "biometric_registrations",
    decode.list(biometric_registration_decoder()),
  )
  use totps <- decode.field("totps", decode.list(totp_decoder()))
  use password <- decode.field("password", decode.optional(password_decoder()))
  use roles <- decode.field("roles", decode.list(decode.string))
  use created_at <- decode.field("created_at", decode.string)
  use status <- decode.field("status", status_decoder())
  decode.success(data.User(
    user_id:,
    name:,
    emails:,
    phone_numbers:,
    providers:,
    webauthn_registrations:,
    biometric_registrations:,
    totps:,
    password:,
    roles:,
    created_at:,
    status:,
  ))
}

pub fn session_attributes_decoder() -> decode.Decoder(data.SessionAttributes) {
  use ip_address <- decode.field("ip_address", decode.string)
  use user_agent <- decode.field("user_agent", decode.string)
  decode.success(data.SessionAttributes(ip_address:, user_agent:))
}

pub fn email_factor_decoder() -> decode.Decoder(data.EmailFactor) {
  use email_address <- decode.field("email_address", decode.string)
  use email_id <- decode.field("email_id", decode.string)
  decode.success(data.EmailFactor(email_address:, email_id:))
}

pub fn authentication_factor_decoder() -> decode.Decoder(
  data.AuthenticationFactor,
) {
  use created_at <- decode.field("created_at", decode.string)
  use delivery_method <- decode.field("delivery_method", decode.string)
  use email_factor <-
    decode.optional_field(
      "email_factor",
      option.None,
      decode.optional(email_factor_decoder()),
    )
  use last_authenticated_at <- decode.field(
    "last_authenticated_at",
    decode.string,
  )
  use updated_at <- decode.field("updated_at", decode.string)
  use factor_type <- decode.field("type", decode.string)
  decode.success(
    data.AuthenticationFactor(
      created_at:,
      delivery_method:,
      email_factor:,
      last_authenticated_at:,
      updated_at:,
      factor_type:,
    ),
  )
}

fn custom_claims_decoder() -> decode.Decoder(List(#(String, String))) {
  decode.dict(decode.string, decode.string)
  |> decode.map(dict.to_list)
}

pub fn session_decoder() -> decode.Decoder(data.Session) {
  use attributes <- decode.field("attributes", session_attributes_decoder())
  use authentication_factors <-
    decode.field(
      "authentication_factors",
      decode.list(authentication_factor_decoder()),
    )
  use custom_claims <- decode.field("custom_claims", custom_claims_decoder())
  use expires_at <- decode.field("expires_at", decode.string)
  use last_accessed_at <- decode.field("last_accessed_at", decode.string)
  use started_at <- decode.field("started_at", decode.string)
  use session_id <- decode.field("session_id", decode.string)
  use user_id <- decode.field("user_id", decode.string)
  decode.success(
    data.Session(
      attributes:,
      authentication_factors:,
      custom_claims:,
      expires_at:,
      last_accessed_at:,
      started_at:,
      session_id:,
      user_id:,
    ),
  )
}

pub fn session_response_decoder() -> decode.Decoder(data.SessionResponse) {
  use session <- decode.field("session", session_decoder())
  decode.success(data.SessionResponse(session:))
}

pub fn verdict_decoder() -> decode.Decoder(data.Verdict) {
  use authorized <- decode.field("authorized", decode.bool)
  use granting_roles <- decode.field("granting_roles", decode.list(decode.string))
  decode.success(data.Verdict(authorized:, granting_roles:))
}

pub fn session_auth_response_decoder() -> decode.Decoder(
  data.SessionAuthResponse,
) {
  use status_code <- decode.field("status_code", decode.int)
  use request_id <- decode.field("request_id", decode.string)
  use session <- decode.field("session", session_decoder())
  use session_jwt <- decode.field("session_jwt", decode.string)
  use session_token <- decode.field("session_token", decode.string)
  use user <- decode.field("user", user_decoder())
  use verdict <-
    decode.optional_field(
      "verdict",
      option.None,
      decode.optional(verdict_decoder()),
    )
  decode.success(
    data.SessionAuthResponse(
      status_code:,
      request_id:,
      session:,
      session_jwt:,
      session_token:,
      user:,
      verdict:,
    ),
  )
}

pub fn auth_response_decoder() -> decode.Decoder(data.AuthResponse) {
  use status_code <- decode.field("status_code", decode.int)
  use request_id <- decode.field("request_id", decode.string)
  use user <- decode.field("user", user_decoder())
  use session_token <- decode.field("session_token", decode.string)
  use session_jwt <- decode.field("session_jwt", decode.string)
  decode.success(data.AuthResponse(
    status_code:,
    request_id:,
    user:,
    session_token:,
    session_jwt:,
  ))
}
