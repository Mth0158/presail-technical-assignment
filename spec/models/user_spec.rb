RSpec.describe User do
  describe "Validations" do
    %i[meta_mask_address meta_mask_nonce].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end
  end

  describe "Instance methods" do
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
