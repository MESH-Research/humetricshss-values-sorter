# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdviceSubmission, type: :model do
  subject(:instance) do
    create(
      :advice_submission,
      source_advice: source_advice,
      published_advice: published_advice,
      author_name: author_name,
      custom_activity: custom_activity,
      published_activity: published_activity,
      custom_value: custom_value,
      published_value: published_value,
      text: text,
      details: details,
      status: status
    )
  end

  let(:submitter) { create(:user) }
  let(:source_advice) { create(:advice, library: submitter.library) }
  let(:published_advice) { nil }
  let(:author_name) { "" }
  let(:custom_activity) { source_advice.activity.name }
  let(:published_activity) { nil }
  let(:custom_value) { source_advice.value.name }
  let(:published_value) { nil }
  let(:text) { source_advice.text }
  let(:details) { source_advice.details }
  let(:status) { :pending }

  describe "associations" do
    describe "published advice" do
      context "when building the association" do
        subject(:advice) { instance.build_published_advice }

        let(:author_name) { "Dr. Senator" }
        let(:published_activity) { create(:activity, library: Library.main) }
        let(:published_value) { create(:value, library: Library.main) }
        let(:text) { "Some good advice about exercising the value during the activity" }
        let(:details) { "<p>You want more?</p><p>Here is some more</p>" }

        it "builds it with the default attributes" do
          expect(advice).to have_attributes(
            attribution: "Dr. Senator",
            activity: published_activity,
            value: published_value,
            text: "Some good advice about exercising the value during the activity"
          )
          expect(advice.details.body.to_trix_html).to eq "<p>You want more?</p><p>Here is some more</p>"
        end

        context "when attributes are specified" do
          subject(:advice) do
            instance.build_published_advice(
              activity: different_activity,
              text: "Some slightly modified advice about exercising the value during the activity"
            )
          end

          let(:different_activity) { create(:activity, library: Library.main) }

          it "overrides the default attributes with the specified values" do
            expect(advice).to have_attributes(
              attribution: "Dr. Senator",
              activity: different_activity,
              value: published_value,
              text: "Some slightly modified advice about exercising the value during the activity"
            )
            expect(advice.details.body.to_trix_html).to eq "<p>You want more?</p><p>Here is some more</p>"
          end
        end
      end
    end
  end

  describe "validations" do
    subject(:instance) do
      described_class.new(
        source_advice: source_advice,
        published_advice: published_advice,
        author_name: author_name,
        custom_activity: custom_activity,
        published_activity: published_activity,
        custom_value: custom_value,
        published_value: published_value,
        text: text,
        details: details,
        status: status
      )
    end

    it { is_expected.to be_valid }

    describe "#custom_activity" do
      context "when the submission uses a custom activity" do
        before { allow(instance).to receive(:uses_custom_activity?).and_return(true) }

        context "when absent" do
          let(:custom_activity) { nil }

          it "fails validation" do
            expect(instance).not_to be_valid
            expect(instance.errors.messages_for(:custom_activity)).to contain_exactly("can't be blank")
          end
        end

        context "when present" do
          let(:custom_activity) { "Anything" }

          it { is_expected.to be_valid }
        end
      end

      context "when the submission does not use a custom activity" do
        # TRICKY: If not using a custom activity, it must use a published one
        let(:published_activity) { create(:activity, library: Library.main) }

        before { allow(instance).to receive(:uses_custom_activity?).and_return(false) }

        context "when absent" do
          let(:custom_activity) { nil }

          it { is_expected.to be_valid }
        end

        context "when present" do
          let(:custom_activity) { "Anything" }

          it { is_expected.to be_valid }
        end
      end
    end

    describe "#published_activity" do
      context "when absent" do
        let(:published_activity) { nil }

        it { is_expected.to be_valid }
      end

      context "when from a user library" do
        let(:published_activity) { create(:activity, library: user_library) }
        let(:user_library) { create(:user).library }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:published_activity)).to contain_exactly("must belong to the main library")
        end
      end

      context "when from the main library" do
        let(:published_activity) { create(:activity, library: Library.main) }

        it { is_expected.to be_valid }
      end
    end

    describe "#custom_value" do
      context "when the submission uses a custom value" do
        before { allow(instance).to receive(:uses_custom_value?).and_return(true) }

        context "when absent" do
          let(:custom_value) { nil }

          it "fails validation" do
            expect(instance).not_to be_valid
            expect(instance.errors.messages_for(:custom_value)).to contain_exactly("can't be blank")
          end
        end

        context "when present" do
          let(:custom_value) { "Anything" }

          it { is_expected.to be_valid }
        end
      end

      context "when the submission does not use a custom value" do
        # TRICKY: If not using a custom value, it must use a published one
        let(:published_value) { create(:value, library: Library.main) }

        before { allow(instance).to receive(:uses_custom_value?).and_return(false) }

        context "when absent" do
          let(:custom_value) { nil }

          it { is_expected.to be_valid }
        end

        context "when present" do
          let(:custom_value) { "Anything" }

          it { is_expected.to be_valid }
        end
      end
    end

    describe "#published_value" do
      context "when absent" do
        let(:published_value) { nil }

        it { is_expected.to be_valid }
      end

      context "when from a user library" do
        let(:published_value) { create(:value, library: user_library) }
        let(:user_library) { create(:user).library }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:published_value)).to contain_exactly("must belong to the main library")
        end
      end

      context "when from the main library" do
        let(:published_value) { create(:value, library: Library.main) }

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

    describe "#status" do
      context "when absent" do
        let(:status) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:status)).to contain_exactly("can't be blank")
        end
      end

      context "when present" do
        let(:status) { :pending }

        it { is_expected.to be_valid }
      end
    end

    describe "#source_advice" do
      context "when the source advice has already been submitted" do
        before { allow(source_advice).to receive(:submitted?).and_return(true) }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:source_advice)).to contain_exactly("has already been submitted")
        end
      end

      context "when the source advice has not already been submitted" do
        before { allow(source_advice).to receive(:submitted?).and_return(false) }

        it { is_expected.to be_valid }
      end
    end

    describe "#published_advice" do
      context "when the published advice does not belong to the main library" do
        let(:published_advice) { create(:advice, library: submitter.library) }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:published_advice)).to contain_exactly("must belong to the main library")
        end
      end

      context "when the published advice belongs to the main library" do
        let(:published_advice) { create(:advice, library: Library.main) }

        it { is_expected.to be_valid }
      end
    end
  end

  describe "callbacks" do
    subject(:instance) do
      described_class.new(
        source_advice: source_advice,
        published_advice: published_advice,
        author_name: author_name,
        custom_activity: custom_activity,
        published_activity: published_activity,
        custom_value: custom_value,
        published_value: published_value,
        text: text,
        details: details,
        status: status
      )
    end

    let(:text) { "Some good advice about exercising the value during the activity" }
    let(:details) { "<p>You want more?</p><p>Here is some more</p>" }
    let(:mail) { instance_double(ActionMailer::Parameterized::MessageDelivery) }

    before do
      allow(AdviceSubmissionMailer).to receive(:submission_received).with(instance).and_return(mail)
      allow(mail).to receive(:deliver_now)
    end

    it "notifies the admins via email" do
      instance.save!
      expect(AdviceSubmissionMailer).to have_received(:submission_received)
      expect(mail).to have_received(:deliver_now)
    end

    it "stores a copy of the original submission's text and details" do
      expect(instance.submitted_text).to be_nil
      expect(instance.submitted_details).to be_nil
      instance.save!
      expect(instance.submitted_text).to eq text
      expect(instance.submitted_details.body.to_trix_html).to include details
    end
  end

  describe "#uses_custom_activity?" do
    subject(:uses_custom_activity?) { instance.uses_custom_activity? }

    context "when the submission has a published activity" do
      let(:published_activity) { create(:activity, library: Library.main) }

      it { is_expected.to be false }
    end

    context "when the submission does not have a published activity" do
      let(:published_activity) { nil }

      it { is_expected.to be true }
    end
  end

  describe "#uses_custom_value?" do
    subject(:uses_custom_value?) { instance.uses_custom_value? }

    context "when the submission has a published value" do
      let(:published_value) { create(:value, library: Library.main) }

      it { is_expected.to be false }
    end

    context "when the submission does not have a published value" do
      let(:published_value) { nil }

      it { is_expected.to be true }
    end
  end

  describe "#attribution" do
    subject(:attribution) { instance.attribution }

    context "when the author name is blank" do
      let(:author_name) { " " }

      it { is_expected.to eq "a HuMetrics Contributor" }
    end

    context "when the author name is present" do
      let(:author_name) { "Dr. Senator" }

      it { is_expected.to eq "Dr. Senator" }
    end
  end

  describe "#ready_to_publish?" do
    subject(:ready_to_publish?) { instance.ready_to_publish? }

    context "when published_advice is invalid" do
      before do
        instance.build_published_advice
        allow(instance.published_advice).to receive(:valid?).and_return(false)
      end

      it { is_expected.to be false }
    end

    context "when published_advice is valid" do
      before do
        instance.build_published_advice
        allow(instance.published_advice).to receive(:valid?).and_return(true)
      end

      it { is_expected.to be true }
    end
  end

  describe "#accept!" do
    subject(:accept!) { instance.accept! }

    let(:author_name) { "Dr. Senator" }
    let(:published_activity) { create(:activity, library: Library.main) }
    let(:published_value) { create(:value, library: Library.main) }
    let(:text) { "Some good advice about exercising the value during the activity" }
    let(:details) { "<p>You want more?</p><p>Here is some more</p>" }
    let(:mail) { instance_double(ActionMailer::Parameterized::MessageDelivery) }

    before do
      allow(AdviceSubmissionMailer).to receive(:submission_accepted).with(instance).and_return(mail)
      allow(mail).to receive(:deliver_now)
    end

    context "when the submission is not pending" do
      let(:status) { :accepted }

      it "raises the expected error" do
        expect { accept! }.to raise_error(
          described_class::NonpendingSubmissionError,
          "AdviceSubmission has already been accepted"
        )
      end
    end

    context "when the submission is not ready to publish" do
      before { allow(instance).to receive(:ready_to_publish?).and_return(false) }

      it "raises the expected error" do
        expect { accept! }.to raise_error(
          described_class::UnpublishableSubmissionError,
          "AdviceSubmission is not in a publishable state"
        )
      end
    end

    it "changes the submission status to accepted" do
      expect { accept! }.to change(instance, :status).from("pending").to("accepted")
    end

    it "creates the expected advice" do
      expect { accept! }.to change { instance.reload.published_advice }.from(nil).to(
        an_object_having_attributes(
          library: Library.main,
          attribution: "Dr. Senator",
          activity: published_activity,
          value: published_value,
          text: "Some good advice about exercising the value during the activity"
        )
      )
      expect(instance.published_advice.details.body.to_trix_html).to eq "<p>You want more?</p><p>Here is some more</p>"
    end

    it "notifies the contributor via email" do
      accept!
      expect(AdviceSubmissionMailer).to have_received(:submission_accepted)
      expect(mail).to have_received(:deliver_now)
    end
  end

  describe "#decline!" do
    subject(:decline!) { instance.decline! }

    let(:mail) { instance_double(ActionMailer::Parameterized::MessageDelivery) }

    before do
      allow(AdviceSubmissionMailer).to receive(:submission_declined).with(instance).and_return(mail)
      allow(mail).to receive(:deliver_now)
    end

    context "when the submission is not pending" do
      let(:status) { :accepted }

      it "raises the expected error" do
        expect { decline! }.to raise_error(
          described_class::NonpendingSubmissionError,
          "AdviceSubmission has already been accepted"
        )
      end
    end

    it "changes the submission status to declined" do
      expect { decline! }.to change(instance, :status).from("pending").to("declined")
    end

    it "notifies the contributor via email" do
      decline!
      expect(AdviceSubmissionMailer).to have_received(:submission_declined)
      expect(mail).to have_received(:deliver_now)
    end
  end
end
