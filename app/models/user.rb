class User < ApplicationRecord
  validates :meta_mask_address, :meta_mask_nonce, presence: true

  # Instance methods ===========================================================

  def regenerate_meta_mask_nonce!
    update(meta_mask_nonce: self.class.generate_new_nonce)
  end

  # Class methods ==============================================================

  def self.generate_new_nonce
    SecureRandom.hex
  end
end
