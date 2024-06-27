# frozen_string_literal: true

require "rails_helper"

RSpec.describe Advice, type: :model do
  subject(:instance) do
    create(
      :advice,
      library: library,
      activity: activity,
      value: value,
      text: text,
      details: details,
      submission: submission
    )
  end

  let(:owner) { create(:user, first_name: "John", last_name: "Doe") }
  let(:library) { owner.library }
  let(:activity) { create(:activity, library: library, name: "the activity name") }
  let(:value) { create(:value, library: library, name: "the value name") }
  let(:text) { "Some good advice about exercising the value during the activity" }
  let(:details) { "<p>You want more?</p><p>Here is some more</p>" }
  let(:submission) { nil }

  describe "associations" do
    describe "#submission" do
      let(:advice_submission) { build(:advice_submission, source_advice: instance) }

      it "nullifies source_advice when the Advice is destroyed" do
        advice_submission.save!
        expect { instance.reload.destroy }.to change { advice_submission.reload.source_advice }.from(instance).to(nil)
      end

      context "when building the association" do
        let(:advice_submission) { instance.build_submission }

        it "builds it with the default attributes" do
          expect(advice_submission).to have_attributes(
            author_name: "John Doe",
            custom_activity: "the activity name",
            custom_value: "the value name",
            text: "Some good advice about exercising the value during the activity",
            details: an_instance_of(ActionText::RichText),
            status: "pending"
          )
          expect(advice_submission.details.body.to_trix_html).to eq "<p>You want more?</p><p>Here is some more</p>"
        end

        context "when attributes are specified" do
          let(:advice_submission) do
            instance.build_submission(
              author_name: "Dr. John Doe III",
              custom_activity: "a different name",
              text: "Some slightly modified advice about exercising the value during the activity"
            )
          end

          it "overrides the default attributes with the specified values" do
            expect(advice_submission).to have_attributes(
              author_name: "Dr. John Doe III",
              custom_activity: "a different name",
              custom_value: "the value name",
              text: "Some slightly modified advice about exercising the value during the activity",
              details: an_instance_of(ActionText::RichText),
              status: "pending"
            )
            expect(advice_submission.details.body.to_trix_html).to eq "<p>You want more?</p><p>Here is some more</p>"
          end
        end
      end
    end
  end

  describe "validations" do
    subject(:instance) do
      described_class.new(
        library: library,
        activity: activity,
        value: value,
        text: text,
        submission: submission
      )
    end

    it { is_expected.to be_valid }

    describe "#library" do
      context "when absent" do
        let(:activity) { create(:activity) }
        let(:value) { create(:value) }
        let(:library) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:library)).to contain_exactly("must exist")
        end
      end

      context "when present" do
        let(:library) { owner.library }

        it { is_expected.to be_valid }
      end
    end

    describe "#activity" do
      context "when absent" do
        let(:activity) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:activity)).to contain_exactly("must exist")
        end
      end

      context "when from a different library" do
        let(:activity) { create(:activity, library: create(:user).library) }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:activity)).to contain_exactly("must belong to the same library")
        end
      end

      context "when from the same library" do
        let(:activity) { create(:activity, library: library) }

        it { is_expected.to be_valid }
      end
    end

    describe "#value" do
      context "when absent" do
        let(:value) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:value)).to contain_exactly("must exist")
        end
      end

      context "when from a different library" do
        let(:value) { create(:value, library: create(:user).library) }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:value)).to contain_exactly("must belong to the same library")
        end
      end

      context "when from the same library" do
        let(:value) { create(:value, library: library) }

        it { is_expected.to be_valid }
      end
    end

    describe "#text" do
      context "when absent" do
        let(:text) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:text)).to contain_exactly("can't be blank")
        end
      end

      context "when present" do
        let(:text) { "Some good advice about exercising the value during the activity" }

        it { is_expected.to be_valid }
      end
    end
  end

  describe "#submitted?" do
    subject(:submitted?) { instance.submitted? }

    context "when the Advice has no submission" do
      let(:submission) { nil }

      it { is_expected.to be false }
    end

    context "when the Advice has a submission" do
      before { create(:advice_submission, source_advice: instance) }

      it { is_expected.to be true }
    end
  end
end
