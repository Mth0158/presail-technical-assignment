RSpec.describe User do
  describe "Validations" do
    %i[meta_mask_address meta_mask_nonce].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end
  end

  describe "Instance methods" do
    describe "#auth_token" do
      let(:user) { FactoryBot.build(:user) }
      let(:jwt_lib) { class_double("JWT").as_stubbed_const(transfer_nested_constants: true) }
      let(:rails_master_key) { Rails.application.credentials.jwt { "" } }

      it "uses the JWT library to encode the auth token" do
        expect(jwt_lib)
          .to receive(:encode)

        user.auth_token
      end

      it "returns a JWT Token" do
        token = user.auth_token

        expect(token.split(".").size)
          .to eq(3)
      end

      describe "payload" do
        subject do
          JWT.decode(
            user.auth_token,
            rails_master_key,
            true,
            { algorithm: "HS256" }
          ).first
        end

        let(:exp) { described_class::AUTH_TOKEN_TTL.from_now }

        it "embeds a timestamp in 'exp' payload key" do
          expect(subject["exp"])
            .to eq(exp.to_i)
        end

        it "embeds the user id in 'id' payload key" do
          expect(subject["id"])
            .to eq(user.id)
        end
      end

      describe "expiration" do
        before do
          now = Time.zone.now
          expect(Time.zone)
            .to receive(:now)
            .and_return(now - described_class::AUTH_TOKEN_TTL - 1.second)
        end

        it "expires after 7 days" do
          expect do
            JWT.decode(
              user.auth_token,
              rails_master_key,
              true,
              { algorithm: "HS256" }
            )
          end.to raise_error(JWT::ExpiredSignature)
        end
      end
    end

    describe "#regenerate_meta_mask_nonce!" do
      subject { user.regenerate_meta_mask_nonce! }

      let!(:user) { FactoryBot.create(:user) }

      it "updates the user's meta_mask_nonce value" do
        expect { subject }
          .to change { user.meta_mask_nonce }
      end
    end
  end

  describe "Class methods" do
    describe ".from_auth_token(token)" do
      subject { User.from_auth_token(auth_token) }

      let(:user) { FactoryBot.create(:user) }

      context "with a valid token" do
        let(:auth_token) { user.auth_token }

        it "returns corresponding user" do
          expect(subject)
            .to eq(user)
        end
      end

      context "with invalid token" do
        context "because it's malformed" do
          let(:auth_token) { "1234" }

          it "raises InvalidToken error" do
            expect { subject }
              .to raise_error(JWT::DecodeError)
          end
        end

        context "because it's expired" do
          let(:payload) { { id: user.id, exp: 1.hour.ago.to_i } }
          let(:hmac_secret) { Rails.application.credentials.jwt { "" } }
          let(:auth_token) { JWT.encode payload, hmac_secret, "HS256" }

          it "raises InvalidToken error" do
            expect { subject }
              .to raise_error(JWT::ExpiredSignature)
          end
        end
      end
    end

    describe ".generate_new_nonce" do
      subject { described_class.generate_new_nonce }

      it "generates a random value" do
        expect(subject)
          .to be_a(String)
        expect(subject.length)
          .to eq(32)
      end
    end
  end
end
