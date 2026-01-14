import gleam/dynamic/decode
import stytch/data

pub fn user_name_decoder() -> decode.Decoder(data.UserName) {
  use first_name <- decode.field("first_name", decode.optional(decode.string))
  use middle_name <- decode.field("middle_name", decode.optional(decode.string))
  use last_name <- decode.field("last_name", decode.optional(decode.string))
  decode.success(data.UserName(first_name:, middle_name:, last_name:))
}

pub fn auth_response_decoder() -> decode.Decoder(data.AuthResponse) {
  use status_code <- decode.field("status_code", decode.int)
  use request_id <- decode.field("request_id", decode.string)
  use session_token <- decode.field("session_token", decode.string)
  use session_jwt <- decode.field("session_jwt", decode.string)
  decode.success(data.AuthResponse(
    status_code:,
    request_id:,
    session_token:,
    session_jwt:,
  ))
}
