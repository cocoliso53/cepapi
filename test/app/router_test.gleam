import app/router
import gleam/http.{Get}
import gleam/uri
import gleeunit/should
import wisp
import wisp/simulate

pub fn handle_request_get_cep_happy_parh_test() {
  let query_string =
    [
      #("tipoCriterio", "numeroReferencia"),
      #("criterio", "ABC123"),
      #("emisor", "ALBO"),
      #("receptor", "ACTINVER"),
      #("fecha", "02-02-2025"),
      #("beneficiario", "123456789012345678"),
      #("monto", "100"),
    ]
    |> uri.query_to_string
  let response =
    router.handle_request(simulate.request(Get, "/cep?" <> query_string))

  //assert response.status == 200
  should.equal(simulate.read_body(response), "")
}
