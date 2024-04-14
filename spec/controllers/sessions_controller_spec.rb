RSpec.describe SessionsController, type: :request do
  let(:user) { FactoryBot.create(:user) }

  it_behaves_like "identify verifiable"

  describe 'GET new' do
    subject { get root_path }

    it { subject && expect(response).to(have_http_status(:ok)) }
  end

  describe 'POST create' do
    subject { post sessions_path, params: { session: session_params, format: :json } }

    let(:session_params) { { address:, signature:, signature_message: } }
    let(:address) { FactoryBot.attributes_for(:user)[:meta_mask_address] }
    let(:signature) { "" }
    let(:signature_message) { "" }

    context "when the corresponding meta_mask_address user does not exist in our system" do
      it { subject && expect(response).to(have_http_status(:unauthorized)) }
    end

    context "when the corresponding meta_mask_address user exists in our system" do
      let(:user) { FactoryBot.create(:user) }
      let(:address) { user.meta_mask_address }

      context "and the signature is valid" do
        let(:signature) { "0xea253ae788f2c130fa7960086240ad19e43c9419834e10ced00e0d35a4c3bd107e7ab4d1b0b78e8fd9533e4e01df601dd7f0dea57d9a765570de99e8167345481b" }
        let(:signature_message) { "Sign this message to sign in\n\nNonce=7de6524c2fa48fdf164a298685d2a919" }

        before do
          expect_any_instance_of(SessionsController)
            .to receive(:valid_signature?)
            .and_return(true)
        end

        context "and the user's current nonce is the one from the signature message" do
          before do
            expect_any_instance_of(SessionsController)
              .to receive(:valid_nonce?)
              .and_return(true)
          end

          it { subject && expect(response).to(have_http_status(:ok)) }

          it "returns an url for redirecting" do
            subject

            expect(JSON.parse(response.body)["redirect_to_url"])
              .to eq(root_url)
          end

          it "authenticates the user by setting a session cookie" do
            subject

            expect(session[:current_user_id])
              .to eq(user.id)
          end

          it "generates a new meta_mask_nonce for the corresponding user" do
            expect do
              subject
              user.reload
            end
              .to change { user.meta_mask_nonce }
          end
        end

        context "and the user's current nonce is not the one from the signature message" do
          before do
            expect_any_instance_of(SessionsController)
              .to receive(:valid_nonce?)
              .and_return(false)
          end

          it { subject && expect(response).to(have_http_status(:unauthorized)) }
        end
      end

      context "and the signature is not valid" do
        before do
          expect_any_instance_of(SessionsController)
            .to receive(:valid_signature?)
            .and_return(false)
        end

        it { subject && expect(response).to(have_http_status(:unauthorized)) }
      end
    end
  end

  describe 'DELETE destroy' do
    subject { delete sessions_path }

    it { subject && expect(response).to(have_http_status(:redirect)) }
    it { is_expected.to redirect_to(root_path) }

    it "deauthenticates the user by removing the session cookie" do
      subject

      expect(session[:current_user_id])
        .not_to be_present
    end
  end
end
