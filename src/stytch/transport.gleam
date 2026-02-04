import stytch/data
import views/user_page
import wisp.{type Request, type Response}

pub fn user_dashboard_response(
  res: Result(#(data.User, data.SessionToken), String),
  req: Request,
) -> Response {
  case res {
    Ok(#(user, session_token)) -> {
      user_page.user_profile_page(user)
      |> wisp.html_response(200)
      |> wisp.set_cookie(
        req,
        "session_token",
        session_token,
        wisp.Signed,
        60 * 10,
      )
    }
    Error(_) -> wisp.html_response("error al obtener usuario", 400)
  }
}
