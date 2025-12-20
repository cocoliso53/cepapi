import app/html_banxico_parser
import gleam/list
import gleeunit/should

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

pub fn html_field_name_to_json_key_clave_rastreo_test() {
  let string_scenarios = [
    "Clave de rastreo",
    " clave de rastreo ",
    "CLAVE DE RASTREO",
    "Clave de rastero",
  ]

  assert list.map(
      string_scenarios,
      html_banxico_parser.html_field_name_to_json_key,
    )
    == [
      Ok("claveRastreo"),
      Ok("claveRastreo"),
      Ok("claveRastreo"),
      Error("No match found for html content: Clave de rastero"),
    ]
}

pub fn html_field_name_to_json_key_institucion_emisora_test() {
  let string_scenarios = [
    "Institución emisora del pago",
    "Institucion emisora del pago",
    "Instituci&oacute;n emisora del pago",
    "Institución emisora del pag",
  ]

  assert list.map(
      string_scenarios,
      html_banxico_parser.html_field_name_to_json_key,
    )
    == [
      Ok("intitucionEmisora"),
      Ok("intitucionEmisora"),
      Ok("intitucionEmisora"),
      Error("No match found for html content: Institución emisora del pag"),
    ]
}

pub fn html_field_name_to_json_key_institucion_receptora_test() {
  let string_scenarios = [
    "Institución receptora del pago",
    "Institucion receptora del pago",
    "Instituci&oacute;n receptora del pago",
    "Institución receptor del pago",
  ]

  assert list.map(
      string_scenarios,
      html_banxico_parser.html_field_name_to_json_key,
    )
    == [
      Ok("institucionReceptora"),
      Ok("institucionReceptora"),
      Ok("institucionReceptora"),
      Error("No match found for html content: Institución receptor del pago"),
    ]
}

pub fn html_field_name_to_json_key_estado_banxico_test() {
  let string_scenarios = [
    "Estado del pago en Banxico",
    "estado del pago en banxico",
    " ESTADO DEL PAGO EN BANXICO ",
    "Estado del pago en Banxcio",
  ]

  assert list.map(
      string_scenarios,
      html_banxico_parser.html_field_name_to_json_key,
    )
    == [
      Ok("estadoBanxico"),
      Ok("estadoBanxico"),
      Ok("estadoBanxico"),
      Error("No match found for html content: Estado del pago en Banxcio"),
    ]
}

pub fn html_field_name_to_json_key_fecha_recepcion_test() {
  let string_scenarios = [
    "Fecha y hora de recepción",
    "Fecha y hora de recepcion",
    "Fecha y hora de recepci&oacute;n",
    "Fecha y hora de recepcin",
  ]

  assert list.map(
      string_scenarios,
      html_banxico_parser.html_field_name_to_json_key,
    )
    == [
      Ok("fechaRecepcion"),
      Ok("fechaRecepcion"),
      Ok("fechaRecepcion"),
      Error("No match found for html content: Fecha y hora de recepcin"),
    ]
}

pub fn html_field_name_to_json_key_fecha_procesamiento_test() {
  let string_scenarios = [
    "Fecha y hora de procesamiento",
    "fecha y hora de procesamiento",
    "FECHA Y HORA DE PROCESAMIENTO",
    "Fecha y hora de procesameinto",
  ]

  assert list.map(
      string_scenarios,
      html_banxico_parser.html_field_name_to_json_key,
    )
    == [
      Ok("fechaProcesamiento"),
      Ok("fechaProcesamiento"),
      Ok("fechaProcesamiento"),
      Error("No match found for html content: Fecha y hora de procesameinto"),
    ]
}

pub fn html_field_name_to_json_key_cuenta_beneficiaria_test() {
  let string_scenarios = [
    "Cuenta Beneficiaria",
    "cuenta beneficiaria",
    "CUENTA BENEFICIARIA",
    "Cuenta Beneficiria",
  ]

  assert list.map(
      string_scenarios,
      html_banxico_parser.html_field_name_to_json_key,
    )
    == [
      Ok("cuentaBeneficiaria"),
      Ok("cuentaBeneficiaria"),
      Ok("cuentaBeneficiaria"),
      Error("No match found for html content: Cuenta Beneficiria"),
    ]
}

pub fn html_field_name_to_json_key_monto_test() {
  let string_scenarios = [
    "Monto",
    "monto",
    " MONTO ",
    "Montos",
  ]

  assert list.map(
      string_scenarios,
      html_banxico_parser.html_field_name_to_json_key,
    )
    == [
      Ok("monto"),
      Ok("monto"),
      Ok("monto"),
      Error("No match found for html content: Montos"),
    ]
}

/// Should just convert the html key to a json key and make
/// the value a json string
pub fn htlm_tuple_to_json_ready_tuple_happy_path_test() {
  #("Número de Referencia", "161225")
  |> html_banxico_parser.htlm_tuple_to_json_ready_tuple
  |> should.be_ok
}

/// Error should propagate
pub fn htlm_tuple_to_json_ready_tuple_error_path_test() {
  #("mumero de réferencia", "161225")
  |> html_banxico_parser.htlm_tuple_to_json_ready_tuple
  |> should.equal(Error("No match found for html content: mumero de réferencia"))
}

pub fn html_tuples_to_json_tuples_happy_path_test() {
  [
    #("Número de Referencia", "161225"),
    #("Clave de Rastreo", "NU3986LEURU487V8N1SLMDB8FM8O"),
    #("Instituci&oacute;n emisora del pago", "NU MEXICO"),
    #("Instituci&oacute;n receptora del pago", "STP"),
    #("Estado del pago en Banxico", "Liquidado"),
    #("Fecha y hora de recepción", "16/12/2025 12:54:42"),
    #("Fecha y hora de procesamiento", "16/12/2025 12:54:42"),
    #("Cuenta Beneficiaria", "646180537900000009"),
    #("Monto", "9200.00"),
  ]
  |> html_banxico_parser.html_tuples_to_json_tuples
  |> should.be_ok
}

pub fn html_tuples_to_json_tuples_single_field_error_test() {
  [
    #("bad field", "161225"),
    #("Clave de Rastreo", "NU3986LEURU487V8N1SLMDB8FM8O"),
    #("Instituci&oacute;n emisora del pago", "NU MEXICO"),
    #("Instituci&oacute;n receptora del pago", "STP"),
    #("Estado del pago en Banxico", "Liquidado"),
    #("Fecha y hora de recepción", "16/12/2025 12:54:42"),
    #("Fecha y hora de procesamiento", "16/12/2025 12:54:42"),
    #("Cuenta Beneficiaria", "646180537900000009"),
    #("Monto", "9200.00"),
  ]
  |> html_banxico_parser.html_tuples_to_json_tuples
  |> should.equal(Error("No match found for html content: bad field"))
}

pub fn html_tuples_to_json_tuples_multiple_field_error_test() {
  [
    #("bad field", "161225"),
    #("Clave de Rastreo", "NU3986LEURU487V8N1SLMDB8FM8O"),
    #("Instituci&oacute;n emisora del pago", "NU MEXICO"),
    #("Instituci&oacute;n receptora del pago", "STP"),
    #("Estado del pago en Banxico", "Liquidado"),
    #("this one too", "16/12/2025 12:54:42"),
    #("Fecha y hora de procesamiento", "16/12/2025 12:54:42"),
    #("Cuenta Beneficiaria", "646180537900000009"),
    #("and this one", "9200.00"),
  ]
  |> html_banxico_parser.html_tuples_to_json_tuples
  |> should.equal(Error(
    "No match found for html content: bad field, No match found for html content: this one too, No match found for html content: and this one",
  ))
}

pub fn prueba_test() {
  assert html_banxico_parser.prueba() == []
}
