# cepapi

[![Package Version](https://img.shields.io/hexpm/v/cepapi)](https://hex.pm/packages/cepapi)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cepapi/)

```sh
gleam add cepapi@1
```
```gleam
import cepapi

pub fn main() -> Nil {
  // TODO: An example of the project in use
}
```

Further documentation can be found at <https://hexdocs.pm/cepapi>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## Project Structure

- `module/transport` builds request payloads/URLs and remains pure.
- `module/codec` owns JSON decoding/encoding for API data.
- `module/client` handles HTTP calls and returns raw/decoded data.
- `module/service` orchestrates client + codec and exposes domain-focused results.
- `module/data` contains types definitions 
- `app/router` adapts requests/responses and stays thin (no business logic).
- `views` contains HTML string builders for rendering pages.


## TODO
- Better, consistent enpoint namings