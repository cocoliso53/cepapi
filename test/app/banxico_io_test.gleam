import app/banxico_io
import gleeunit/should
import mock/mock_io

pub fn get_html_cep_banxico_happy_path_test() {
  let data = [
    #("tipoCriterio", "numeroReferencia"),
    #("criterio", "161225"),
    #("emisor", "NUMEXICO"),
    #("receptor", "STP"),
    #("fecha", "16-12-2025"),
    #("beneficiario", "646180537900000009"),
    #("monto", "9200"),
  ]

  let res = banxico_io.get_html_cep_banxico(data, mock_io.send)
  should.be_ok(res)
}

pub fn get_html_cep_banxico_bad_list_test() {
  let data = [
    #("tipoCriterio", "numeroReferencia"),
    #("criterio", "161225"),
    #("emisor", "NUMEXICO"),
    #("receptor", "STP"),
    #("fecha", "16-12-2025"),
    #("monto", "9200"),
  ]

  let res = banxico_io.get_html_cep_banxico(data, mock_io.send)
  should.be_error(res)
}
