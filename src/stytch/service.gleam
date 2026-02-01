import gleam/http/response
import gleam/json
import gleam/list
import gleam/string
import stytch/codec
import stytch/data

fn json_decode_errors_to_string(decode_error: json.DecodeError) -> String {
  case decode_error {
    json.UnexpectedEndOfInput -> "UnexpectedEndOfInput while decoding response"
    json.UnexpectedByte(s) -> s
    json.UnexpectedSequence(s) -> s
    json.UnableToDecode(errors_list) ->
      errors_list |> list.map(codec.decode_error_to_string) |> string.join(", ")
  }
}

fn extract_user_and_token_from_parsed_data(
  res: Result(data.AuthResponse, json.DecodeError),
) -> Result(#(data.User, data.SessionJWT), String) {
  case res {
    Ok(t) -> Ok(#(t.user, t.session_jwt))
    Error(e) -> e |> json_decode_errors_to_string |> Error
  }
}

// This function should be the one used after sending
// a request to stytch oauth/authenticate endpoint and
// handle the result, either a valid auth response 
// or an error. Check https://stytch.com/docs/api/oauth-authenticate
// for more details on the structrure of the response
pub fn get_user_and_token(
  res: Result(response.Response(String), data.ClientError),
) -> Result(#(data.User, data.SessionJWT), String) {
  case res {
    Ok(resp) -> {
      resp.body
      |> json.parse(codec.auth_response_decoder())
      |> extract_user_and_token_from_parsed_data
    }

    Error(_) -> Error("error")
  }
}
