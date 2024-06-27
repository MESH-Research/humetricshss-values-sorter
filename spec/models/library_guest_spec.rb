# frozen_string_literal: true

require "rails_helper"

RSpec.describe LibraryGuest, type: :model do
  subject(:instance) { described_class.new(library: library, guest: guest) }

  let(:library) { create(:user).library }
  let(:guest) { create(:user) }

  describe "validations" do
    it { is_expected.to be_valid }

    describe "#library" do
      context "when absent" do
        let(:library) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:library)).to contain_exactly("must exist")
        end
      end

      context "when present" do
        let(:library) { Library.main }

        it { is_expected.to be_valid }
      end
    end

    describe "#guest" do
      context "when absent" do
        let(:guest) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:guest)).to contain_exactly("must exist")
        end
      end

      context "when present" do
        let(:guest) { create(:user) }

        it { is_expected.to be_valid }

        context "when already a guest of the given library" do
          before { create(:library_guest, library: library, guest: guest) }

          it "fails validation" do
            expect(instance).not_to be_valid
            expect(instance.errors.messages_for(:guest)).to contain_exactly("has already joined this library")
          end
        end

        context "when the guest is the owner of the library" do
          let(:guest) { library.owner }

          it "fails validation" do
            expect(instance).not_to be_valid
            expect(instance.errors.messages_for(:guest)).to contain_exactly("must not be the library's owner")
          end
        end
      end
    end
  end
end
