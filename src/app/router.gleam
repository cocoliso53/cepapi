import app/banxico_io
import app/cep_data
import app/html_banxico_parser
import app/web
import gleam/http.{Get, Post}
import gleam/json
import gleam/list
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

fn prueba_query(req: Request) -> Response {
  req
  |> wisp.get_query
  |> echo
  |> list.map(fn(x) {
    let #(k, v) = x
    #(k, json.string(v))
  })
  |> json.object
  |> json.to_string
  |> wisp.json_response(200)
}

fn mock_cep_html(_req: Request) -> String {
  "<table  id=\"xxx\" class=\"styled-table vertical\" style=\"margin: auto;\">
      <tbody>
        <tr><td>Número de Referencia</td><td>161225</td></tr>
        <tr><td>Clave de Rastreo</td><td>NU3986LEURU487V8N1SLMDB8FM8O</td></tr>
        <tr><td>Instituci&oacute;n emisora del pago</td><td>NU MEXICO</td></tr>
        <tr><td>Instituci&oacute;n receptora del pago</td><td>STP</td></tr>
        <tr><td>Estado del pago en Banxico</td><td>Liquidado</td></tr>
        <tr><td>Fecha y hora de recepción</td><td>16/12/2025 12:54:42</td></tr>
        <tr><td>Fecha y hora de procesamiento</td><td>16/12/2025 12:54:42</td></tr>
                        
        <tr class=\"columna-cuenta\"><td>Cuenta Beneficiaria</td><td>646180537900000009</td></tr>                       
        <tr class=\"columna-monto\"><td>Monto</td><td>9200.00</td></tr>
                                                    
      </tbody>
    </table> "
}

fn get_cep(req: Request) -> Response {
  use <- wisp.require_method(req, Get)
  req
  |> mock_cep_html
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

fn prueba_banxico_conection(req: Request) -> Response {
  cep_data.UserCepData(
    tipo_criterio: "numeroReferencia",
    criterio: "161225",
    emisor: "NUMEXICO",
    receptor: "STP",
    fecha: "16-12-2025",
    beneficiario: "646180537900000009",
    monto: "9200",
  )
  |> banxico_io.get_html_cep_banxico
  |> echo
  |> fn(x) {
    case x {
      Ok(s) -> wisp.html_response(s, 200)
      Error(_) -> wisp.bad_request("Error feo")
    }
  }
}

pub fn handle_request(req: Request) -> Response {
  use _req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> html_hello(req)

    ["json"] -> json_hello(req)

    ["cep"] -> get_cep(req)

    ["prueba"] -> prueba_query(req)

    ["banxico"] -> prueba_banxico_conection(req)

    _ -> wisp.not_found()
  }
}
