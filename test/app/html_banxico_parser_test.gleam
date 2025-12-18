import app/html_banxico_parser
import gleam/list

pub fn html_field_name_to_json_key_numero_referencia_test() {
  let string_scenarios = [
    "Numero de referencia",
    "Número de referencia",
    "número de referencia",
    "Múmero de Referencia",
  ]

  assert list.map(
      string_scenarios,
      html_banxico_parser.html_field_name_to_json_key,
    )
    == [
      Ok("numeroReferencia"),
      Ok("numeroReferencia"),
      Ok("numeroReferencia"),
      Error("No match found for html content: Múmero de Referencia"),
    ]
}

pub fn prueba_test() {
  assert html_banxico_parser.prueba() == []
}
