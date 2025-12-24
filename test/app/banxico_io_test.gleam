import app/banxico_io
import app/cep_data
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/list
import gleam/uri
import gleeunit/should

fn valid_query_string(query: String) -> Bool {
  let query_as_list = uri.parse_query(query)
  let required_keys = [
    "tipoCriterio",
    "emisor",
    "receptor",
    "fecha",
    "cuenta",
    "receptorParticipante",
    "monto",
    "captcha",
    "criterio",
    "tipoConsulta",
  ]

  case query_as_list {
    Error(_) -> False
    Ok([]) -> False
    Ok(l) ->
      list.all(l, fn(x) {
        let #(k, _) = x
        list.contains(required_keys, k)
      })
      && list.length(l) == 10
  }
}

/// this function should behave the same way banxico's
/// website does when we try to get data from it
fn mock_send(
  req: request.Request(String),
) -> Result(response.Response(String), httpc.HttpError) {
  echo req.body
  let valid_params = valid_query_string(req.body)
  let full_html_response =
    "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,maximum-scale=1.0,user-scalable=no\" />\n
<meta charset=\"utf-8\" />\n
<meta http-equiv=\"X-UA-Compatible\" content=\"IE=9; IE=8; IE=7; IE=edge\" />\n
<link rel=\"apple-touch-icon\" href=\"images/icon.png\"/>\n
<link rel=\"shortcut icon\" href=\"images/icon.png\">\n
<!--Bootstrap-->\n
<!--<link href=\"//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap-glyphicons.css\" rel=\"stylesheet\">\n
<link rel=stylesheet href=\"css/bootstrap/bootstrap.min.css\" type=\"text/css\">\n
<link rel=\"stylesheet\" href=\"css/bootstrap/dataTables.bootstrap.min.css\" type=\"text/css\" >-->\n
<link rel=stylesheet href=\"css/fuentes.css\" type=\"text/css\">\n
<link rel=stylesheet href=\"css/cep-min.css\" type=\"text/css\">\n
\n
<!-- JQuery -->\n
<script type=\"text/javascript\" src=\"js/jquery-3.6.1.min.js\"></script>\n
<script type=\"text/javascript\" src=\"js/jquery-ui.min.js\"></script>\n
<script type=\"text/javascript\" src=\"js/jquery/jquery.dataTables.min.js\"></script>\n
<script type=\"text/javascript\" src=\"js/datepicker-es.js\"></script>\n
\n
<!-- Validations -->\n
<script type=\"text/javascript\" src=\"js/validations/validateInput.js\"></script>\n
<script type=\"text/javascript\" src=\"js/validations/validateEvents.js\"></script>\n
<script type=\"text/javascript\" src=\"js/validations/validateWriting.js\"></script>\n
<script type=\"text/javascript\" src=\"js/validations/validationBussines.js\"></script>\n
\n
<meta http-equiv=\"Content-type\" content=\"text/html; charset=UTF-8\" />\n
<style type=\"text/css\">\n
@media screen and (min-width: 481px) and (min-height: 551px) {\n
  .contenido-wide { width: 1100px !important; max-width: 1100px !important; }\n
  .contenido-wide table { width: fit-content !important; }\n
}\n
#consultaMISPEI { padding: 0 !important; margin: 15px !important; }\n
#htmlCEP tr { padding-top: 2px; padding-bottom: 2px; }\n
</style>\n
<div class=\"bg-banxico title-bar\">\n
  <i class=\"icono-header icon-list\"></i>\n
  Información del estado del pago\n
</div>\n
<div class=\"cuerpo-msg\">\n
<div id=\"consultaMISPEI\" style=\"padding: 15px;box-sizing: border-box;overflow-x: auto;\">\n
<div class=\"info\" style=\"margin-bottom: 10px;\"><center><strong>Con la información proporcionada se identificó el siguiente pago:</strong></center></div>\n
<br><br>\n
<table id=\"xxx\" class=\"styled-table vertical\" style=\"margin: auto;\"><tbody>\n
<tr><td>Número de Referencia</td><td>161225</td></tr>\n
<tr><td>Clave de Rastreo</td><td>NU3986LEURU487V8N1SLMDB8FM8O</td></tr>\n
<tr><td>Institución emisora del pago</td><td>NU MEXICO</td></tr>\n
<tr><td>Institución receptora del pago</td><td>STP</td></tr>\n
<tr><td>Estado del pago en Banxico</td><td>Liquidado</td></tr>\n
<tr><td>Fecha y hora de recepción</td><td>16/12/2025 12:54:42</td></tr>\n
<tr><td>Fecha y hora de procesamiento</td><td>16/12/2025 12:54:42</td></tr>\n
<tr><td>Cuenta Beneficiaria</td><td>646180537900000009</td></tr>\n
<tr><td>Monto</td><td>9200.00</td></tr>\n
</tbody></table>\n
<br><br>\n
<div class=\"aviso-info\"><p class=\"aviso\">IMPORTANTE: Esta consulta no es un Comprobante Electrónico de Pago (CEP).</p></div>\n
</div>\n
</div>\n
<script>\n
function start_download() {\n
  var html = document.getElementById('consultaMISPEI').innerHTML;\n
  document.getElementById('htmlCEP').value = html;\n
  return true;\n
}\n
</script>\n"

  let error_html =
    "<div class=\"bg-banxico title-bar\">\n
    <i class=\"icono-header icon-warning3\"></i>\n
    Error\n
</div>\n
<div id=\"#error_div\">\n
    <div class=\"info\">\n
        <p style=\"padding: 10px;max-width: 500px; text-align: center;\">\n
            No existe un criterio (clave de rastreo o número de referencia)\n
        </p>\n
    </div>\n
</div>\n
<input type=\"hidden\" name=\"varHideCaptcha\" value=\"true\"/>\n"

  case valid_params {
    True ->
      response.new(200)
      |> response.set_body(full_html_response)
      |> Ok
    False ->
      response.new(200)
      |> response.set_body(error_html)
      |> Ok
  }
}

pub fn get_html_cep_banxico_happy_path_test() {
  let data =
    Ok([
      #("tipoCriterio", "numeroReferencia"),
      #("criterio", "161225"),
      #("emisor", "NUMEXICO"),
      #("receptor", "STP"),
      #("fecha", "16-12-2025"),
      #("beneficiario", "646180537900000009"),
      #("monto", "9200"),
    ])

  let res = banxico_io.get_html_cep_banxico(data, mock_send)
  should.be_ok(res)
}

pub fn get_html_cep_banxico_bad_list_test() {
  let data =
    Ok([
      #("tipoCriterio", "numeroReferencia"),
      #("criterio", "161225"),
      #("emisor", "NUMEXICO"),
      #("receptor", "STP"),
      #("fecha", "16-12-2025"),
      #("monto", "9200"),
    ])

  let res = banxico_io.get_html_cep_banxico(data, mock_send)
  should.be_error(res)
}

pub fn get_html_cep_banxico_passing_error_test() {
  let data = Error("Generic error")

  let res = banxico_io.get_html_cep_banxico(data, mock_send)
  should.be_error(res)
}
