import envoy
import gleam/http.{Post}
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/json
import stytch/data
import wisp.{type Request}

fn list_to_json_string_body(params: List(#(String, json.Json))) -> String {
  params
  |> json.object
  |> json.to_string
}

fn token_to_json_string_body(token: String) -> String {
  let json_list_params = [
    #("token", json.string(token)),
    #("session_duration_minutes", json.int(60)),
  ]

  list_to_json_string_body(json_list_params)
}

fn session_token_to_json_string_body(session_token: String) -> String {
  list_to_json_string_body([#("session_token", json.string(session_token))])
}

pub fn stytch_token_auth(
  send_fn: fn(request.Request(String)) ->
    Result(response.Response(String), httpc.HttpError),
  token: String,
) -> Result(response.Response(String), data.ClientError) {
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
          Error(error) -> Error(data.HttpError(error))
        }
      }
    Error(_) -> Error(data.ElseError("Something went wrong with base_req"))
  }
}

pub fn authenticate_session(
  send_fn: fn(request.Request(String)) ->
    Result(response.Response(String), httpc.HttpError),
  session_token: String,
) -> Result(response.Response(String), data.ClientError) {
  let base_req = request.to("https://test.stytch.com/v1/sessions/authenticate")
  let assert Ok(auth_token) = envoy.get("AUTH_TOKEN")

  case base_req {
    Ok(r) ->
      r
      |> request.set_header("Content-Type", "application/json")
      |> request.set_header("Authorization", "Basic " <> auth_token)
      |> request.set_method(Post)
      |> request.set_body(session_token_to_json_string_body(session_token))
      |> send_fn
      |> fn(x) {
        case x {
          Ok(result) -> Ok(result)
          Error(error) -> Error(data.HttpError(error))
        }
      }
    Error(_) -> Error(data.ElseError("Something went wrong with base_req"))
  }
}
