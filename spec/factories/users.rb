FactoryBot.define do
  factory :user do
    meta_mask_address { Faker::Blockchain::Ethereum.address }
    meta_mask_nonce { User.generate_new_nonce }
  end
end
