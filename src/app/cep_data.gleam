// Takes data from the user, parse it, and make it ready to send to banxico
import gleam/dict
import gleam/function
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import gleam/string

// Data that comes from the user, ie the request
// might be worhit to think of a better name
pub type UserCepData {
  UserCepData(
    tipo_criterio: String,
    criterio: String,
    emisor: String,
    receptor: String,
    fecha: String,
    beneficiario: String,
    monto: String,
  )
}

// TODO: implement real function
fn format_fecha(fecha: String) -> String {
  function.identity(fecha)
}

// TOOD: implement real function
fn format_monto(monto: String) -> String {
  function.identity(monto)
}

fn string_list_to_usercepdata(
  params_list: List(#(String, String)),
) -> UserCepData {
  let params_dict = dict.from_list(params_list)
  let get_param_value = fn(k) {
    params_dict |> dict.get(k) |> result.unwrap("")
  }
  UserCepData(
    tipo_criterio: "tipoCriterio" |> get_param_value,
    criterio: "criterio" |> get_param_value,
    emisor: "emisor" |> get_param_value,
    receptor: "receptor" |> get_param_value,
    fecha: "fecha" |> get_param_value |> format_fecha,
    beneficiario: "beneficiario" |> get_param_value,
    monto: "monto" |> get_param_value |> format_monto,
  )
}

pub fn query_list_to_usercepdata(
  query_list: List(#(String, String)),
) -> Result(UserCepData, String) {
  let required_keys =
    set.from_list([
      "tipoCriterio",
      "criterio",
      "emisor",
      "receptor",
      "fecha",
      "beneficiario",
      "monto",
    ])

  let present_keys =
    query_list
    |> list.map(fn(x) {
      let #(k, _) = x
      k
    })
    |> set.from_list

  let missing_keys =
    set.difference(required_keys, present_keys)
    |> set.to_list
    |> list.sort(by: string.compare)

  case missing_keys {
    [] -> Ok(string_list_to_usercepdata(query_list))
    _ -> Error("Missing fields: " <> string.join(missing_keys, ", "))
  }
}

pub fn institution_code_from_name(name: String) -> option.Option(String) {
  case name {
    "ACTINVER" -> option.Some("40133")
    "AFIRME" -> option.Some("40062")
    "ALBO" -> option.Some("90721")
    "ARCUS FI" -> option.Some("90706")
    "ASPINTEGRAOPC" -> option.Some("90659")
    "AUTOFIN" -> option.Some("40128")
    "AZTECA" -> option.Some("40127")
    "BABIEN" -> option.Some("37166")
    "BAJIO" -> option.Some("40030")
    "BANAMEX" -> option.Some("40002")
    "BANCOCOVALTO" -> option.Some("40154")
    "BANCOMEXT" -> option.Some("37006")
    "BANCOPPEL" -> option.Some("40137")
    "BANCOS3" -> option.Some("40160")
    "BANCREA" -> option.Some("40152")
    "BANJERCITO" -> option.Some("37019")
    "BANKAOOL" -> option.Some("40147")
    "BANKOFAMERICA" -> option.Some("40106")
    "BANKOFCHINA" -> option.Some("40159")
    "BANOBRAS" -> option.Some("37009")
    "BANORTE" -> option.Some("40072")
    "BANREGIO" -> option.Some("40058")
    "BANSI" -> option.Some("40060")
    "BANXICO" -> option.Some("2001")
    "BARCLAYS" -> option.Some("40129")
    "BBASE" -> option.Some("40145")
    "BBVAMEXICO" -> option.Some("40012")
    "BMONEX" -> option.Some("40112")
    "CAJAPOPMEXICA" -> option.Some("90677")
    "CAJATELEFONIST" -> option.Some("90683")
    "CASHICUENTA" -> option.Some("90715")
    "CBINTERCAM" -> option.Some("90630")
    "CIBANCO" -> option.Some("40143")
    "CIBOLSA" -> option.Some("90631")
    "CITIMEXICO" -> option.Some("40124")
    "CLS" -> option.Some("90901")
    "CODIVALIDA" -> option.Some("90903")
    "COMPARTAMOS" -> option.Some("40130")
    "CONSUBANCO" -> option.Some("40140")
    "CREDICAPITAL" -> option.Some("90652")
    "CREDICLUB" -> option.Some("90688")
    "CRISTOBALCOLON" -> option.Some("90680")
    "CUENCA" -> option.Some("90723")
    "DONDE" -> option.Some("40151")
    "FINAMEX" -> option.Some("90616")
    "FINCOMUN" -> option.Some("90634")
    "FINCOPAY" -> option.Some("90734")
    "FOMPED" -> option.Some("90689")
    "FONDEADORA" -> option.Some("90699")
    "FONDOFIRA" -> option.Some("90685")
    "GBM" -> option.Some("90601")
    "HEYBANCO" -> option.Some("40167")
    "HIPOTECARIAFED" -> option.Some("37168")
    "HSBC" -> option.Some("40021")
    "ICBC" -> option.Some("40155")
    "INBURSA" -> option.Some("40036")
    "INDEVAL" -> option.Some("90902")
    "INMOBILIARIO" -> option.Some("40150")
    "INTERCAMBANCO" -> option.Some("40136")
    "INVEX" -> option.Some("40059")
    "JPMORGAN" -> option.Some("40110")
    "KLAR" -> option.Some("90661")
    "KUSPIT" -> option.Some("90653")
    "LIBERTAD" -> option.Some("90670")
    "MASARI" -> option.Some("90602")
    "MERCADOPAGOW" -> option.Some("90722")
    "MEXPAGO" -> option.Some("90720")
    "MIFEL" -> option.Some("40042")
    "MIZUHOBANK" -> option.Some("40158")
    "MONEXCB" -> option.Some("90600")
    "MUFG" -> option.Some("40108")
    "MULTIVABANCO" -> option.Some("40132")
    "NAFIN" -> option.Some("37135")
    "NUMEXICO" -> option.Some("90638")
    "NVIO" -> option.Some("90710")
    "PAGATODO" -> option.Some("40148")
    "PEIBO" -> option.Some("90732")
    "PROFUTURO" -> option.Some("90620")
    "SABADELL" -> option.Some("40156")
    "SANTANDER" -> option.Some("40014")
    "SCOTIABANK" -> option.Some("40044")
    "SHINHAN" -> option.Some("40157")
    "SPINBYOXXO" -> option.Some("90728")
    "STP" -> option.Some("90646")
    "TESORED" -> option.Some("90703")
    "TRANSFER" -> option.Some("90684")
    "UALA" -> option.Some("40138")
    "UNAGRA" -> option.Some("90656")
    "VALMEX" -> option.Some("90617")
    "VALUE" -> option.Some("90605")
    "VECTOR" -> option.Some("90608")
    "VEPORMAS" -> option.Some("40113")
    "VOLKSWAGEN" -> option.Some("40141")

    _ -> option.None
  }
}

pub fn tipo_criterio_code_from_name(criterio: String) -> option.Option(String) {
  case criterio {
    "numeroReferencia" -> option.Some("R")
    "claveRastreo" -> option.Some("T")
    _ -> option.None
  }
}

pub fn cep_data_to_params_list(
  data: UserCepData,
) -> Result(List(#(String, String)), String) {
  // Try to asign values needed to hit banxico endpoint
  let tipo_criterio_code = tipo_criterio_code_from_name(data.tipo_criterio)
  let emisor_code = institution_code_from_name(data.emisor)
  let receptor_code = institution_code_from_name(data.receptor)

  // Return Errors if institutions don't match, might need to expand this in the future
  // to check for correct amount and date
  case tipo_criterio_code, emisor_code, receptor_code {
    option.None, _, _ -> Error("Tipo de criterio no valido")
    _, option.None, _ -> Error("Emisor incorrecto")
    _, _, option.None -> Error("Receptor incorrecto")
    _, _, _ ->
      Ok([
        // Using default value of "", but we should never be in this situation
        // case clause before should catch these and return Error(...) instead
        #("tipoCriterio", option.unwrap(tipo_criterio_code, "")),
        #("emisor", option.unwrap(emisor_code, "")),
        #("receptor", option.unwrap(receptor_code, "")),
        #("fecha", data.fecha),
        #("cuenta", data.beneficiario),
        #("receptorParticipante", "0"),
        #("monto", data.monto),
        #("captcha", "c"),
        #("criterio", data.criterio),
        // Tipo de consulta 0 -> html, 1 -> download file
        #("tipoConsulta", "0"),
      ])
  }
}

/// The result of this function should be use to create 
/// a query string  to send to banxico 
pub fn query_list_to_banxico_params_list(
  query_list: List(#(String, String)),
) -> Result(List(#(String, String)), String) {
  query_list
  |> query_list_to_usercepdata
  |> fn(x) {
    case x {
      Error(error) -> Error(error)
      Ok(data) -> data |> cep_data_to_params_list
    }
  }
}
