# frozen_string_literal: true

require "rails_helper"

RSpec.describe Library, type: :model do
  subject(:instance) { owner.library }

  let(:owner) { create(:user) }
  let(:activities) { [] }
  let(:values) { [] }
  let(:advice) { [] }

  before do
    instance.activities = activities
    instance.values = values
    instance.advice = advice
  end

  describe "associations" do
    before { instance.save! }

    describe "#activities" do
      let(:activities) { build_list(:activity, 1, library: nil) }

      it "is destroyed alongside the corresponding library" do
        expect { instance.destroy }.to change(activities.first, :destroyed?).from(false).to(true)
      end
    end

    describe "#values" do
      let(:values) { build_list(:value, 1, library: nil) }

      it "is destroyed alongside the corresponding library" do
        expect { instance.destroy }.to change(values.first, :destroyed?).from(false).to(true)
      end
    end

    describe "#advice" do
      let(:activities) { build_list(:activity, 1, library: nil) }
      let(:values) { build_list(:value, 1, library: nil) }

      # TRICKY: Validations force us to create the activities/values before the advice in this test
      let(:advice) { [] }
      let(:actual_advice) { build_list(:advice, 1, library: instance, activity: activities.first, value: values.first) }

      before do
        instance.save!
        actual_advice.first.save!
      end

      it "is destroyed alongside the corresponding library" do
        expect { instance.destroy }.to change(actual_advice.first.reload, :destroyed?).from(false).to(true)
      end
    end

    describe "#library_guests" do
      let(:library_guests) { create_list(:library_guest, 3, library: instance) }

      it "are destroyed alongside the corresponding library" do
        library_guest_ids = library_guests.map(&:id)
        expect { instance.destroy }.to change { LibraryGuest.where(id: library_guest_ids).empty? }.from(false).to(true)
      end
    end
  end

  describe "validations" do
    it { is_expected.to be_valid }

    describe "#owner" do
      context "when the library is the main library" do
        subject(:instance) { described_class.main }

        context "when empty" do
          let(:owner) { nil }

          it { is_expected.to be_valid }
        end

        context "when present" do
          before { instance.owner = create(:user) }

          it "fails validation" do
            expect(instance).not_to be_valid
            expect(instance.errors.messages_for(:owner)).to contain_exactly("must be blank", "has already been taken")
          end
        end
      end

      context "when the library is not the main library" do
        subject(:instance) { owner.library }

        context "when empty" do
          subject(:instance) { described_class.new(owner: nil) }

          it "fails validation" do
            expect(instance).not_to be_valid
            expect(instance.errors.messages_for(:owner)).to contain_exactly("can't be blank")
          end
        end

        context "when present" do
          let(:owner) { create(:user) }

          it { is_expected.to be_valid }

          context "when the owner already has a library" do
            subject(:instance) { described_class.new(owner: owner) }

            it "fails validation" do
              expect(instance).not_to be_valid
              expect(instance.errors.messages_for(:owner)).to contain_exactly("has already been taken")
            end
          end
        end
      end
    end
  end

  describe "callbacks" do
    before { allow(SecureRandom).to receive(:uuid).and_return "75cf41c0-8308-4714-91a2-c899b72f0a23" }

    context "when the library has no sharing code" do
      before { instance.sharing_code = nil }

      it "sets the library's sharing code when it is validated" do
        expect { instance.valid? }.to change(instance, :sharing_code).from(nil).to ("75cf41c0-8308-4714-91a2-c899b72f0a23")
      end
    end

    context "when the library has a sharing code" do
      before { instance.sharing_code = "267e4a0c-ab53-47f1-92c0-eadae7bf1cff" }

      it "does not change the library's sharing code when it is validated" do
        expect { instance.valid? }.not_to change(instance, :sharing_code).from("267e4a0c-ab53-47f1-92c0-eadae7bf1cff")
      end
    end
  end

  describe ".main" do
    subject(:main) { described_class.main }

    it "returns the main library" do
      expect(main).to be_main
    end
  end

  describe ".main?" do
    subject(:main?) { library.main? }

    let(:library) { nil }

    context "when called on a library with the main library's id" do
      let(:library) { described_class.find_or_create_by!(id: described_class::MAIN_LIBRARY_ID) }

      it { is_expected.to be true }
    end

    context "when called on a library with a different id" do
      let(:library) { create(:user).library }

      it { is_expected.to be false }
    end
  end

  describe ".reroll_sharing_code" do
    subject(:reroll_sharing_code) { instance.reroll_sharing_code }

    before do
      instance.update(sharing_code: "267e4a0c-ab53-47f1-92c0-eadae7bf1cff")
      allow(SecureRandom).to receive(:uuid).and_return "75cf41c0-8308-4714-91a2-c899b72f0a23"
    end

    it "changes the sharing code, but does not save it" do
      expect { reroll_sharing_code }.to change(instance, :sharing_code).from("267e4a0c-ab53-47f1-92c0-eadae7bf1cff").to("75cf41c0-8308-4714-91a2-c899b72f0a23")
      expect(instance.reload.sharing_code).to eq "267e4a0c-ab53-47f1-92c0-eadae7bf1cff"
    end
  end

  describe ".reroll_sharing_code!" do
    subject(:reroll_sharing_code!) { instance.reroll_sharing_code! }

    before do
      instance.update(sharing_code: "267e4a0c-ab53-47f1-92c0-eadae7bf1cff")
      allow(SecureRandom).to receive(:uuid).and_return "75cf41c0-8308-4714-91a2-c899b72f0a23"
    end
    it "changes the sharing code and saves it" do
      expect { reroll_sharing_code! }.to change(instance, :sharing_code).from("267e4a0c-ab53-47f1-92c0-eadae7bf1cff").to("75cf41c0-8308-4714-91a2-c899b72f0a23")
      expect(instance.reload.sharing_code).to eq "75cf41c0-8308-4714-91a2-c899b72f0a23"
    end
  end
end
