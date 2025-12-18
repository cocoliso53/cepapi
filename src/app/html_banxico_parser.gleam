import gleam/json.{type Json}
import gleam/list
import gleam/regexp
import html_parser.{type Element, Content, EndElement, StartElement}

/// This is simply a parser, so it shouln't throw any errors
/// if anything it will just return an empty list
pub fn find_content(html: List(Element)) -> List(#(String, String)) {
  case html {
    [] -> []
    [
      Content(field_name),
      EndElement("td"),
      StartElement("td", _, _),
      Content(field_value),
      ..tail
    ] -> list.append([#(field_name, field_value)], find_content(tail))
    [_, ..tail] -> find_content(tail)
  }
}

pub fn html_field_name_to_json_key(
  html_content: String,
) -> Result(String, String) {
  let assert Ok(re_numref) =
    regexp.from_string("(?i)^\\s*n[uú]mero de referencia\\s*$")
  let assert Ok(re_clave_rastreo) =
    regexp.from_string("(?i)^\\s*clave de rastreo\\s*$")
  let assert Ok(re_emisor) =
    regexp.from_string(
      "(?i)^\\s*instituci(?:ó|o|&oacute;)n emisora del pago\\s*$",
    )
  let assert Ok(re_receptor) =
    regexp.from_string(
      "(?i)^\\s*instituci(?:ó|o|&oacute;)n receptora del pago\\s*$",
    )
  let assert Ok(re_estado) =
    regexp.from_string("(?i)^\\s*estado del pago en banxico\\s*$")
  let assert Ok(re_fecha_recepcion) =
    regexp.from_string("(?i)^\\s*fecha y hora de recepci(?:ó|o|&oacute;)n\\s*$")
  let assert Ok(re_fecha_procesamiento) =
    regexp.from_string("(?i)^\\s*fecha y hora de procesamiento\\s*$")
  let assert Ok(re_beneficiario) =
    regexp.from_string("(?i)^\\s*cuenta beneficiaria\\s*$")
  let assert Ok(re_monto) = regexp.from_string("(?i)^\\s*monto\\s*$")

  let pattern_to_key = [
    #(re_numref, "numeroReferencia"),
    #(re_clave_rastreo, "claveRastreo"),
    #(re_emisor, "intitucionEmisora"),
    #(re_receptor, "institucionReceptora"),
    #(re_estado, "estadoBanxico"),
    #(re_fecha_recepcion, "fechaRecepcion"),
    #(re_fecha_procesamiento, "fechaProcesamiento"),
    #(re_beneficiario, "cuentaBeneficiaria"),
    #(re_monto, "monto"),
  ]

  pattern_to_key
  |> list.find(fn(x) {
    let #(re, _) = x
    regexp.check(with: re, content: html_content)
  })
  |> fn(x) {
    case x {
      Ok(#(_, val)) -> Ok(val)
      Error(_) -> Error("No match found for html content: " <> html_content)
    }
  }
}

/// html_tuple should be one of the elements of the list
/// returned by find_content
pub fn htlm_tuple_to_json_ready_tuple(
  html_tuple: #(String, String),
) -> Result(#(String, Json), String) {
  let #(html_key, html_value) = html_tuple
  let json_key = html_field_name_to_json_key(html_key)

  case json_key {
    Ok(key) -> Ok(#(key, json.string(html_value)))
    Error(error) -> Error(error)
  }
}

pub fn prueba() {
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
  |> html_parser.as_list
  |> find_content
}
