import app/router
import gleam/http.{Get}
import gleam/uri
import gleeunit/should
import mock/mock_io
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
    router.handle_request_with_sender(
      simulate.request(Get, "/cep?" <> query_string),
      mock_io.send,
    )

  should.equal(response.status, 200)
  should.equal(
    simulate.read_body(response),
    "{\"numeroReferencia\":\"161225\",\"claveRastreo\":\"NU3986LEURU487V8N1SLMDB8FM8O\",\"institucionEmisora\":\"NU MEXICO\",\"institucionReceptora\":\"STP\",\"estadoBanxico\":\"Liquidado\",\"fechaRecepcion\":\"16/12/2025 12:54:42\",\"fechaProcesamiento\":\"16/12/2025 12:54:42\",\"cuentaBeneficiaria\":\"646180537900000009\",\"monto\":\"9200.00\"}",
  )
}
