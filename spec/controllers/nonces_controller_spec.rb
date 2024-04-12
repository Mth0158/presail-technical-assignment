RSpec.describe NoncesController, type: :request do
  let(:user) { FactoryBot.create(:user) }

  describe 'GET show' do
    subject { get nonce_path(meta_mask_address, params: { format: :json }) }

    context "when the corresponding meta_mask_address user's exists in our system" do
      let(:meta_mask_address) { user.meta_mask_address }

      it { subject && expect(response).to(have_http_status(:ok)) }

      it "returns the user's current meta_mask_nonce value" do
        subject

        expect(JSON.parse(response.body)["value"])
          .to eq(user.meta_mask_nonce)
      end
    end

    context "when the corresponding meta_mask_address user's does not yet exist in our system" do
      let(:meta_mask_address) { FactoryBot.attributes_for(:user)[:meta_mask_address] }
      let(:created_user) { User.last }

      it { subject && expect(response).to(have_http_status(:ok)) }

      it "creates a new user with the corresponding meta_mask_address" do
        expect { subject }
          .to change(User, :count)
          .by(1)
      end

      it "returns the created user's meta_mask_nonce value" do
        subject

        expect(JSON.parse(response.body)["value"])
          .to eq(created_user.meta_mask_nonce)
      end
    end
  end
end
