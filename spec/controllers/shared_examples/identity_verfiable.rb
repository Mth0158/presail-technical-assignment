RSpec.shared_examples_for 'identify verifiable' do
  describe "#valid_signature?" do
    subject { described_class.new.valid_signature?(from: address, signature:, message: signature_message) }

    let(:address) { FactoryBot.attributes_for(:user)[:meta_mask_address] }
    let(:signature) { "0xea253ae788f2c130fa7960086240ad19e43c9419834e10ced00e0d35a4c3bd107e7ab4d1b0b78e8fd9533e4e01df601dd7f0dea57d9a765570de99e8167345481b" }
    let(:signature_message) { "Sign this message to sign in\n\nNonce=#{meta_mask_nonce}" }
    let(:meta_mask_nonce) { "da6be92bc2f05f23c6252b6709c20fb8" }

    context "when the signature and signature_message returns a public_key" do
      before do
        expect(Eth::Key)
          .to receive(:personal_recover)
          .with(signature_message, signature)
          .and_return(:anything)
      end

      context "and the address guessed from the public_key is the given address" do
        before do
          expect(Eth::Utils)
            .to receive(:public_key_to_address)
            .with(:anything)
            .and_return(address)
        end

        it "returns true" do
          expect(subject)
            .to be true
        end
      end

      context "and the address guessed from the public_key is not the given address" do
        before do
          expect(Eth::Utils)
            .to receive(:public_key_to_address)
            .with(:anything)
            .and_return(:any_address)
        end

        it "returns false" do
          expect(subject)
            .to be false
        end
      end
    end

    context "when the signature and signature_message do not return a public_key" do
      before do
        expect(Eth::Key)
          .to receive(:personal_recover)
          .with(signature_message, signature)
          .and_return(nil)
      end

      it "returns false" do
        expect(subject)
          .to be false
      end
    end
  end

  describe "#valid_nonce?" do
    subject { described_class.new.valid_nonce?(user, signature_message) }

    let(:user) { FactoryBot.create(:user, meta_mask_nonce:) }

    context "when the provided signature_message contains the user current meta_mask_nonce" do
      let(:meta_mask_nonce) { "da6be92bc2f05f23c6252b6709c20fb8" }
      let(:signature_message) { "Sign this message to sign in\n\nNonce=#{meta_mask_nonce}" }

      it "returns true" do
        expect(subject)
          .to be true
      end
    end

    context "when the provided signature_message does not contain the user current meta_mask_nonce" do
      let(:meta_mask_nonce) { "da6be92bc2f05f23c6252b6709c20fb8" }
      let(:wrong_nonce) { meta_mask_nonce + "s" }
      let(:signature_message) { "Sign this message to sign in\n\nNonce=#{wrong_nonce}" }

      it "returns false" do
        expect(subject)
          .to be false
      end
    end
  end
end
