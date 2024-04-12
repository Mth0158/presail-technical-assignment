RSpec.describe ApplicationController do
  describe "#current_user" do
    context "with auth token" do
      let!(:user) { FactoryBot.create(:user) }

      before :each do
        controller.send(:cookies).signed[:jwt] = user.auth_token
      end

      context "and no user" do
        before { user.destroy }

        it "returns nil" do
          expect(controller.current_user)
            .to be_nil
        end
      end

      context "and valid user" do
        it "returns authenticated user" do
          expect(controller.current_user)
            .to eq(user)
        end
      end
    end

    context "with no auth token" do
      it "returns nil" do
        expect(controller.current_user)
          .to be_nil
      end
    end

    context "with an expired auth token" do
      let(:user) { FactoryBot.create(:user) }
      let(:payload) { { user_id: user.id, exp: 1.hour.ago.to_i } }
      let(:hmac_secret) { ENV.fetch("RAILS_MASTER_KEY") { "" } }
      let(:token) { JWT.encode payload, hmac_secret, "HS256" }

      before { controller.params[:token] = token }

      it "returns nil" do
        expect(controller.current_user)
          .to be_nil
      end
    end
  end
end
