import app/cep_data
import gleam/option.{None, Some}
import gleeunit/should

pub fn tipo_criterio_code_from_name_numero_referencia_test() {
  assert cep_data.tipo_criterio_code_from_name("numeroReferencia") == Some("R")
}

pub fn tipo_criterio_code_from_name_clave_rastreo_test() {
  assert cep_data.tipo_criterio_code_from_name("claveRastreo") == Some("T")
}

pub fn tipo_criterio_code_from_name_invalid_option_test() {
  assert cep_data.tipo_criterio_code_from_name("invalid") == None
}

pub fn cep_data_to_params_list_happy_path_test() {
  let data =
    cep_data.UserCepData(
      tipo_criterio: "claveRastreo",
      criterio: "ABC123",
      emisor: "ALBO",
      receptor: "ACTINVER",
      fecha: "02-02-2025",
      beneficiario: "123456789012345678",
      monto: "100",
    )

  let res = cep_data.cep_data_to_params_list(data)
  should.equal(
    res,
    Ok([
      #("tipoCriterio", "T"),
      #("emisor", "90721"),
      #("receptor", "40133"),
      #("fecha", "02-02-2025"),
      #("cuenta", "123456789012345678"),
      #("receptorParticipante", "0"),
      #("monto", "100"),
      #("captcha", "c"),
      #("criterio", "ABC123"),
      #("tipoConsulta", "0"),
    ]),
  )
}

pub fn cep_data_to_params_list_wrong_institution_test() {
  let data =
    cep_data.UserCepData(
      tipo_criterio: "claveRastreo",
      criterio: "ABC123",
      emisor: "INVALIDO",
      receptor: "ACTINVER",
      fecha: "02-02-2025",
      beneficiario: "123456789012345678",
      monto: "100",
    )

  let res = cep_data.cep_data_to_params_list(data)
  assert res == Error("Emisor incorrecto")
}

pub fn cep_data_to_params_list_wrong_criterio_test() {
  let data =
    cep_data.UserCepData(
      tipo_criterio: "INVALIDO",
      criterio: "ABC123",
      emisor: "ALBO",
      receptor: "ACTINVER",
      fecha: "02-02-2025",
      beneficiario: "123456789012345678",
      monto: "100",
    )

  let res = cep_data.cep_data_to_params_list(data)
  assert res == Error("Tipo de criterio no valido")
}
