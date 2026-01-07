import gleam/option

pub type UserName {
  UserName(
    first_name: option.Option(String),
    middle_name: option.Option(String),
    last_name: option.Option(String),
  )
}

pub type Email {
  Email(email_id: String, email: String, verified: Bool)
}

pub type PhoneNumber {
  PhoneNumber(phone_id: String, phone_number: String, verified: Bool)
}

pub type Provider {
  Provider(
    oauth_user_registration_id: String,
    provider_subject: String,
    provider_type: String,
    profile_picture_url: String,
    locale: String,
  )
}

pub type WebauthnRegistration {
  WebauthnRegistration(
    webauthn_registration_id: String,
    domain: String,
    user_agent: String,
    authenticator_type: String,
    verified: Bool,
    name: String,
  )
}

pub type BiometricRegistration {
  BiometricRegistration(biometric_registration_id: String, verified: Bool)
}

pub type Totp {
  Totp(totp_id: String, verified: Bool)
}

pub type CryptoWallet {
  CryptoWallet(
    crypto_wallet_id: String,
    crypto_wallet_address: String,
    crypto_wallet_type: String,
    verified: Bool,
  )
}

pub type Password {
  Password(password_id: String, requires_reset: Bool)
}

pub type Status {
  Pending
  Active
}

pub type User {
  User(
    user_id: String,
    name: UserName,
    emails: List(Email),
    phone_numbers: List(PhoneNumber),
    providers: List(Provider),
    webauthn_registrations: List(WebauthnRegistration),
    biometric_registrations: List(BiometricRegistration),
    totps: List(Totp),
    password: option.Option(Password),
    roles: List(String),
    created_at: String,
    status: Status,
  )
}
