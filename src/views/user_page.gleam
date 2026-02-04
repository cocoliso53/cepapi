import gleam/list
import gleam/option
import gleam/string
import stytch/data

fn display_name(name: data.UserName) -> String {
  let first = option.unwrap(name.first_name, or: "")
  let middle = option.unwrap(name.middle_name, or: "")
  let last = option.unwrap(name.last_name, or: "")

  [first, middle, last]
  |> list.filter(fn(part) { part != "" })
  |> string.join(" ")
}

fn primary_email(emails: List(data.Email)) -> String {
  case list.first(emails) {
    Ok(email) -> email.email
    Error(_) -> ""
  }
}

pub fn user_profile_page(user: data.User) -> String {
  let name = display_name(user.name)
  let email = primary_email(user.emails)

  "<!doctype html>\n"
  <> "<html lang=\"en\">\n"
  <> "<head>\n"
  <> "  <meta charset=\"utf-8\">\n"
  <> "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
  <> "  <title>User</title>\n"
  <> "</head>\n"
  <> "<body>\n"
  <> "  <h1>User</h1>\n"
  <> "  <p>Name: "
  <> name
  <> "</p>\n"
  <> "  <p>Email: "
  <> email
  <> "</p>\n"
  <> "  <a href=\"/user/subscription"
  <> "\">Subscritions</a>\n"
  <> "</body>\n"
  <> "</html>\n"
}

pub fn suscriptions_page(token: String) -> String {
  "<!doctype html>\n"
  <> "<html lang=\"en\">\n"
  <> "<head>\n"
  <> "  <meta charset=\"utf-8\">\n"
  <> "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
  <> "  <title>Suscriptions</title>\n"
  <> "</head>\n"
  <> "<body>\n"
  <> "  <h1>Suscriptions</h1>\n"
  <> "  <p>Token: "
  <> token
  <> "</p>\n"
  <> "</body>\n"
  <> "</html>\n"
}
