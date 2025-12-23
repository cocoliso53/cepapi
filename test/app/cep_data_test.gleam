import app/cep_data
import gleam/option.{None, Some}
import gleeunit/should

pub fn query_list_to_usercepdata_happy_path_test() {
  [
    #("tipoCriterio", "numeroReferencia"),
    #("criterio", "ABC123"),
    #("emisor", "ALBO"),
    #("receptor", "ACTINVER"),
    #("fecha", "02-02-2025"),
    #("beneficiario", "123456789012345678"),
    #("monto", "100"),
  ]
  |> cep_data.query_list_to_usercepdata
  |> should.equal(
    Ok(cep_data.UserCepData(
      "numeroReferencia",
      "ABC123",
      "ALBO",
      "ACTINVER",
      "02-02-2025",
      "123456789012345678",
      "100",
    )),
  )
}

// NOTE: Notice that here we don't do any validation
// on the fields value of the fields
pub fn query_list_to_usercepdata_value_typo_test() {
  [
    #("tipoCriterio", "numeroreferencia"),
    #("criterio", "ABC123"),
    #("emisor", "ALBO"),
    #("receptor", "ACTINVER"),
    #("fecha", "02-02-2025"),
    #("beneficiario", "123456789012345678"),
    #("monto", "100"),
  ]
  |> cep_data.query_list_to_usercepdata
  |> should.equal(
    Ok(cep_data.UserCepData(
      "numeroreferencia",
      "ABC123",
      "ALBO",
      "ACTINVER",
      "02-02-2025",
      "123456789012345678",
      "100",
    )),
  )
}

pub fn query_list_to_usercepdata_key_typo_test() {
  [
    #("tipocriterio", "numeroReferencia"),
    #("criterio", "ABC123"),
    #("emisor", "ALBO"),
    #("receptor", "ACTINVER"),
    #("fecha", "02-02-2025"),
    #("beneficiario", "123456789012345678"),
    #("monto", "100"),
  ]
  |> cep_data.query_list_to_usercepdata
  |> should.equal(Error("Missing fields: tipoCriterio"))
}

pub fn query_list_to_usercepdata_missing_fields_test() {
  [
    #("tipoCriterio", "numeroReferencia"),
    #("criterio", "ABC123"),
    #("fecha", "02-02-2025"),
    #("beneficiario", "123456789012345678"),
    #("monto", "100"),
  ]
  |> cep_data.query_list_to_usercepdata
  |> should.equal(Error("Missing fields: emisor, receptor"))
}

pub fn query_list_to_usercepdata_happy_path_extra_fields_test() {
  [
    #("tipoCriterio", "numeroReferencia"),
    #("criterio", "ABC123"),
    #("emisor", "ALBO"),
    #("receptor", "ACTINVER"),
    #("fecha", "02-02-2025"),
    #("beneficiario", "123456789012345678"),
    #("monto", "100"),
    #("extra", "extra"),
  ]
  |> cep_data.query_list_to_usercepdata
  |> should.equal(
    Ok(cep_data.UserCepData(
      "numeroReferencia",
      "ABC123",
      "ALBO",
      "ACTINVER",
      "02-02-2025",
      "123456789012345678",
      "100",
    )),
  )
}

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

pub fn query_list_to_banxico_params_list_happy_path_test() {
  [
    #("tipoCriterio", "numeroReferencia"),
    #("criterio", "ABC123"),
    #("emisor", "ALBO"),
    #("receptor", "ACTINVER"),
    #("fecha", "02-02-2025"),
    #("beneficiario", "123456789012345678"),
    #("monto", "100"),
  ]
  |> cep_data.query_list_to_banxico_params_list
  |> should.equal(
    Ok([
      #("tipoCriterio", "R"),
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

pub fn query_list_to_banxico_params_list_missing_flieds_test() {
  [
    #("tipoCriterio", "numeroReferencia"),
    #("criterio", "ABC123"),
    #("emisor", "ALBO"),
    #("receptor", "ACTINVER"),
    #("fecha", "02-02-2025"),
  ]
  |> cep_data.query_list_to_banxico_params_list
  |> should.equal(Error("Missing fields: beneficiario, monto"))
}

pub fn query_list_to_banxico_params_list_invalid_insitution_test() {
  [
    #("tipoCriterio", "numeroReferencia"),
    #("criterio", "ABC123"),
    #("emisor", "ALBO"),
    #("receptor", "INVALIDO"),
    #("fecha", "02-02-2025"),
    #("beneficiario", "123456789012345678"),
    #("monto", "100"),
  ]
  |> cep_data.query_list_to_banxico_params_list
  |> should.equal(Error("Receptor incorrecto"))
}

// NOTE: here we so have some validation for inputs
pub fn query_list_to_banxico_params_list_value_typo_test() {
  [
    #("tipoCriterio", "numeroreferencia"),
    #("criterio", "ABC123"),
    #("emisor", "ALBO"),
    #("receptor", "INVALIDO"),
    #("fecha", "02-02-2025"),
    #("beneficiario", "123456789012345678"),
    #("monto", "100"),
  ]
  |> cep_data.query_list_to_banxico_params_list
  |> should.equal(Error("Tipo de criterio no valido"))
}

pub fn query_list_to_banxico_params_list_key_typo_test() {
  [
    #("tipocriterio", "numeroReferencia"),
    #("criterio", "ABC123"),
    #("emisor", "ALBO"),
    #("receptor", "INVALIDO"),
    #("fecha", "02-02-2025"),
    #("beneficiario", "123456789012345678"),
    #("monto", "100"),
  ]
  |> cep_data.query_list_to_banxico_params_list
  |> should.equal(Error("Missing fields: tipoCriterio"))
}
