class User < ApplicationRecord
  AUTH_TOKEN_TTL = 7.days

  validates :meta_mask_address, :meta_mask_nonce, presence: true

  # Instance methods ===========================================================

  def auth_token
    payload = {
      id:,
      exp: self.class::AUTH_TOKEN_TTL.from_now.to_i
    }

    hmac_secret = Rails.application.credentials.jwt { "" }
    JWT.encode(payload, hmac_secret, "HS256")
  end

  def regenerate_meta_mask_nonce!
    update(meta_mask_nonce: self.class.generate_new_nonce)
  end

  # Class methods ==============================================================

  def self.from_auth_token(token)
    payload = JWT.decode(
      token,
      Rails.application.credentials.jwt { "" },
      true,
      { algorithm: "HS256" }
    ).first

    find(payload["id"].to_i)
  end

  def self.generate_new_nonce
    SecureRandom.hex
  end
end
