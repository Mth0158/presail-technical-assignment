require "active_support/concern"

module IdentityVerifiable
  extend ActiveSupport::Concern

  included do
    def valid_signature?(from:, signature:, message:)
      public_key = Eth::Key.personal_recover(message, signature)
      return false if public_key.nil?

      address = Eth::Utils.public_key_to_address(public_key)
      from.downcase == address.downcase
    end

    def valid_nonce?(user, message)
      nonce = message.match(/Nonce=(?<nonce>.+)$/).try(:[], :nonce)
      user.meta_mask_nonce == nonce
    end
  end
end
