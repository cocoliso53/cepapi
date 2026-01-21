pub fn auth_call() {
  case x {
    Ok(resp) -> {
      resp.body
      |> json.parse(codec.auth_response_decoder())
      |> fn(y) {
        case y {
          Ok(t) -> {
            let session = t.session_jwt
            let user = t.user

            user_page.user_profile_page(user)
            |> wisp.html_response(200)
            |> wisp.set_cookie(
              req,
              "session_jwt",
              session,
              wisp.Signed,
              60 * 10,
            )
          }

          Error(_) -> wisp.html_response("error al obtener usuario", 400)
        }
      }
    }
    Error(_) -> wisp.html_response("error", 400)
  }
}
