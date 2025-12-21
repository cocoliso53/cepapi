import app/router
import gleam/http.{Get}
import wisp
import wisp/simulate

pub fn handle_request_get_cep_happy_parh_test() {
  let response = router.handle_request(simulate.request(Get, "/cep"))

  assert response.body
    == wisp.Text(
      "{\"numeroReferencia\":\"161225\",\"claveRastreo\":\"NU3986LEURU487V8N1SLMDB8FM8O\",\"institucionEmisora\":\"NU MEXICO\",\"institucionReceptora\":\"STP\",\"estadoBanxico\":\"Liquidado\",\"fechaRecepcion\":\"16/12/2025 12:54:42\",\"fechaProcesamiento\":\"16/12/2025 12:54:42\",\"cuentaBeneficiaria\":\"646180537900000009\",\"monto\":\"9200.00\"}",
    )

  assert response.status == 200
}
