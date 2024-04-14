RSpec.describe ApplicationController do
  describe "#current_user" do
    context "with an active session" do
      let!(:user) { FactoryBot.create(:user) }

      before :each do
        request.session[:current_user_id] = user.id
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

    context "without session / expired session" do
      it "returns nil" do
        expect(controller.current_user)
          .to be_nil
      end
    end
  end
end
