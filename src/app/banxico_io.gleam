import app/cep_data.{type UserCepData}
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/uri

fn make_banxico_request(
  params_as_list: List(#(String, String)),
) -> Result(String, String) {
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
      |> httpc.send
      |> fn(x) {
        case x {
          Ok(resp) -> Ok(resp.body)
          Error(_) -> Error("Error getting cep from banxico ")
        }
      }
    Error(_) -> Error("Can't create base request")
  }
}

/// Should be hte main function, takes the data as the user sends it
/// and return either an HTML or an Error
pub fn get_html_cep_banxico(data: UserCepData) -> Result(String, String) {
  data
  |> cep_data.cep_data_to_params_list
  |> echo
  |> fn(x) {
    case x {
      Ok(params) -> make_banxico_request(params)
      Error(_) -> Error("Error making params list")
    }
  }
}
