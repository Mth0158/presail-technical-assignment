class User < ApplicationRecord
  AUTH_TOKEN_TTL = 7.days

  validates :meta_mask_address, :meta_mask_nonce, presence: true

  # Instance methods ===========================================================

  def auth_token
    payload = {
      id:,
      exp: self.class::AUTH_TOKEN_TTL.from_now.to_i
    }

    hmac_secret = ENV.fetch("RAILS_MASTER_KEY") { "" }
    JWT.encode(payload, hmac_secret, "HS256")
  end

  def regenerate_meta_mask_nonce!
    update(meta_mask_nonce: self.class.generate_random_value)
  end

  # Class methods ==============================================================

  def self.from_auth_token(token)
    payload = JWT.decode(
      token,
      ENV.fetch("RAILS_MASTER_KEY") { "" },
      true,
      { algorithm: "HS256" }
    ).first

    find(payload["id"].to_i)
  end

  def self.generate_random_value
    SecureRandom.hex
  end
end
