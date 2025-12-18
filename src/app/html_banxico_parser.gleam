import gleam/list
import html_parser.{type Element, Content, EndElement, StartElement}

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

// TODO: function to go from HTML text to appropiate json response text

pub fn prueba() {
  "<table  id=\"xxx\" class=\"styled-table vertical\" style=\"margin: auto;\">
                    <tbody>
                        <tr><td>Número de Referencia</td><td>161225</td></tr>
                        <tr><td>Clave de Rastreo</td><td>NU3986LEURU487V8N1SLMDB8FM8O</td></tr>
                        <tr><td>Instituci&oacute;n emisora del pago</td><td>NU MEXICO</td></tr>
                        <tr><td>Instituci&oacute;n receptora del pago</td><td>STP</td></tr>
                        <tr><td>Estado del pago en Banxico</td><td>Liquidado</td></tr>
                        <tr><td>Fecha y hora de recepción</td><td>16/12/2025 12:54:42</td></tr>
                        <tr><td>Fecha y hora de procesamiento</td><td>16/12/2025 12:54:42</td></tr>
                        
                            <tr class=\"columna-cuenta\"><td>Cuenta Beneficiaria</td><td>646180537900000009</td></tr>
                         
                            <tr class=\"columna-monto\"><td>Monto</td><td>9200.00</td></tr>
                                                    
                    </tbody>
                </table> "
  |> html_parser.as_list
  |> find_content
  |> echo
}
