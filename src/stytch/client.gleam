import envoy
import gleam/http.{Post}
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/json
import wisp.{type Request}

pub type ClientError {
  HttpError(httpc.HttpError)
  ElseError(String)
}

fn token_to_json_string_body(token: String) -> String {
  let json_list_params = [
    #("token", json.string(token)),
    #("session_duration_minutes", json.int(60)),
  ]

  json_list_params
  |> json.object
  |> json.to_string
}

pub fn stytch_token_auth(
  send_fn: fn(request.Request(String)) ->
    Result(response.Response(String), httpc.HttpError),
  token: String,
) -> Result(response.Response(String), ClientError) {
  let base_req = request.to("https://test.stytch.com/v1/oauth/authenticate")
  let assert Ok(auth_token) = envoy.get("AUTH_TOKEN")

  case base_req {
    Ok(r) ->
      r
      |> request.set_header("Content-Type", "application/json")
      |> request.set_header("Authorization", "Basic " <> auth_token)
      |> request.set_method(Post)
      |> request.set_body(token_to_json_string_body(token))
      |> send_fn
      |> fn(x) {
        case x {
          Ok(result) -> Ok(result)
          Error(error) -> Error(HttpError(error))
        }
      }
    Error(_) -> Error(ElseError("Something went wrong with base_req"))
  }
}
