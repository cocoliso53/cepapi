import app/banxico_io
import app/html_banxico_parser
import app/web
import gleam/http.{Get}
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/json
import wisp.{type Request, type Response}

fn json_hello(req: Request) -> Response {
  use <- wisp.require_method(req, Get)
  let response_object =
    json.object([#("foo", json.string("foo")), #("bar", json.string("bar"))])

  let result = Ok(json.to_string(response_object))

  case result {
    Ok(json) -> wisp.json_response(json, 201)
    //Error(_) -> wisp.unprocessable_content()
  }
}

fn html_hello(_req: Request) -> Response {
  let body = "<h1>Hello, Joe!</h1>"

  wisp.html_response(body, 200)
}

fn get_cep(
  req: Request,
  send_fn: fn(request.Request(String)) ->
    Result(response.Response(String), httpc.HttpError),
) -> Response {
  use <- wisp.require_method(req, Get)
  req
  |> wisp.get_query
  |> banxico_io.get_html_cep_banxico(send_fn)
  |> html_banxico_parser.parse_html_to_json_tuple
  |> fn(x) {
    case x {
      Ok(l) ->
        l
        |> json.object
        |> json.to_string
        |> wisp.json_response(200)
      Error(error) -> wisp.bad_request(error)
    }
  }
}

pub fn handle_request(req: Request) -> Response {
  handle_request_with_sender(req, httpc.send)
}

pub fn handle_request_with_sender(
  req: Request,
  send_fn: fn(request.Request(String)) ->
    Result(response.Response(String), httpc.HttpError),
) -> Response {
  use _req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> html_hello(req)

    ["json"] -> json_hello(req)

    ["cep"] -> get_cep(req, send_fn)

    _ -> wisp.not_found()
  }
}
