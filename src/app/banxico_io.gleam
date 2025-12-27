import app/cep_data.{type UserCepData}
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/uri

fn make_banxico_request(
  params_as_list: List(#(String, String)),
) -> Result(request.Request(String), String) {
  let base_req = request.to("https://www.banxico.org.mx/cep/valida.do")

  case base_req {
    Ok(req) ->
      req
      |> request.set_header(
        "content-type",
        "application/x-www-form-urlencoded; charset=UTF-8",
      )
      |> request.set_method(http.Post)
      |> request.set_body(uri.query_to_string(params_as_list))
      |> Ok
    Error(_) -> Error("Error while building banxico request")
  }
}

fn unwrap_response(
  resp: Result(response.Response(String), httpc.HttpError),
) -> Result(String, String) {
  case resp {
    Ok(r) if r.status >= 200 && r.status < 400 -> Ok(r.body)
    Ok(r) if r.status >= 400 && r.status < 500 ->
      Error("Banxico returned 400 error")
    Ok(_) -> Error("Error procesing the request")
    Error(_) -> Error("Error procesing the request")
  }
}

/// Should be the main function, takes the data as the user sends it
/// and return either an HTML or an Error
/// we use send_fn to make tests easier to perform 
/// by building a mock send function on the test file
pub fn get_html_cep_banxico(
  data: List(#(String, String)),
  send_fn: fn(request.Request(String)) ->
    Result(response.Response(String), httpc.HttpError),
) -> Result(String, String) {
  data
  |> cep_data.query_list_to_banxico_params_list
  |> fn(x) {
    case x {
      Ok(params) ->
        params
        |> make_banxico_request
        |> fn(y) {
          case y {
            Ok(req) -> req |> send_fn |> unwrap_response
            Error(error) -> Error(error)
          }
        }
      Error(_) -> Error("Error making params list")
    }
  }
}
