import gleam/json.{type Json}
import gleam/list
import gleam/regexp
import gleam/string
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
    #(re_emisor, "institucionEmisora"),
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

fn concat_errors(json_tuples: List(Result(_, String))) -> Result(_, String) {
  json_tuples
  |> list.filter(fn(x) {
    case x {
      Error(_) -> True
      _ -> False
    }
  })
  |> list.map(fn(x) {
    case x {
      Error(error) -> error
      // this clause should never fire
      // because of the filter above
      _ -> ""
    }
  })
  |> fn(x) { Error(string.join(x, ", ")) }
}

/// This will only work as intended if 
/// html_tuples is not empty
pub fn html_tuples_to_json_tuples(
  html_tuples: List(#(String, String)),
) -> Result(List(#(String, Json)), String) {
  let json_tuples = list.map(html_tuples, htlm_tuple_to_json_ready_tuple)

  let ok_results = list.filter_map(html_tuples, htlm_tuple_to_json_ready_tuple)

  case list.length(json_tuples) == list.length(ok_results) {
    True -> Ok(ok_results)
    False -> concat_errors(json_tuples)
  }
}

/// This should be the entrypoint function of this file
/// html_string should be a string with 
/// valid HTML content/page, else will
/// return Error, return json tuples tu be returned to client
pub fn parse_html_to_json_tuple(
  html_string: String,
) -> Result(List(#(String, Json)), String) {
  html_string
  |> html_parser.as_list
  |> find_content
  |> fn(x) {
    case x {
      [] -> Error("HTML not formated as expected " <> html_string)
      _ -> html_tuples_to_json_tuples(x)
    }
  }
}
