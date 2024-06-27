# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContributorApplication, type: :model do
  subject(:instance) do
    described_class.new(
      user: user,
      discovery: discovery,
      interest: interest,
      perspective: perspective,
      status: status
    )
  end

  let(:user) { create(:user) }
  let(:discovery) { "I discovered the application via referral" }
  let(:interest) { "I want to help make academia more accessible" }
  let(:perspective) { "I am a professor at Kickass University" }
  let(:status) { :pending }

  describe "associations" do
    subject(:instance) do
      create(
        :contributor_application,
        discovery: discovery,
        interest: interest,
        perspective: perspective,
        status: status,
        user: user
      )
    end

    describe "#user" do
      it "nullifies its association when the application is destroyed" do
        expect { instance.destroy }.to change { user.reload.contributor_application }.from(instance).to(nil)
      end
    end
  end

  describe "validations" do
    it { is_expected.to be_valid }

    describe "#discovery" do
      context "when absent" do
        let(:discovery) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:discovery)).to contain_exactly("can't be blank")
        end
      end

      context "when present" do
        let(:discovery) { "Anything" }

        it { is_expected.to be_valid }
      end
    end

    describe "#interest" do
      context "when absent" do
        let(:interest) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:interest)).to contain_exactly("can't be blank")
        end
      end

      context "when present" do
        let(:interest) { "Anything" }

        it { is_expected.to be_valid }
      end
    end

    describe "#perspective" do
      context "when absent" do
        let(:perspective) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:perspective)).to contain_exactly("can't be blank")
        end
      end

      context "when present" do
        let(:perspective) { "Anything" }

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

    describe "#user" do
      context "when absent" do
        let(:user) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:user)).to contain_exactly("must exist")
        end
      end

      context "when present" do
        let(:user) { create(:user) }

        it { is_expected.to be_valid }

        context "when the user already has an application" do
          before { create(:contributor_application, user: user) }

          it "fails validation" do
            expect(instance).not_to be_valid
            expect(instance.errors.messages_for(:user)).to contain_exactly("has already been taken")
          end
        end
      end
    end
  end

  describe "callbacks" do
    let(:mail) { instance_double(ActionMailer::Parameterized::MessageDelivery) }

    before do
      allow(ContributorApplicationMailer).to receive(:application_received).with(instance).and_return(mail)
      allow(mail).to receive(:deliver_now)
    end

    it "notifies the admins via email" do
      instance.save!
      expect(ContributorApplicationMailer).to have_received(:application_received)
      expect(mail).to have_received(:deliver_now)
    end
  end

  describe "accept!" do
    subject(:accept!) { instance.accept! }

    let(:mail) { instance_double(ActionMailer::Parameterized::MessageDelivery) }

    before do
      allow(ContributorApplicationMailer).to receive(:application_accepted).with(instance).and_return(mail)
      allow(mail).to receive(:deliver_now)
    end

    it "changes the application status to accepted" do
      expect { accept! }.to change(instance, :status).from("pending").to("accepted")
    end

    it "changes the users role to contributor" do
      expect { accept! }.to change(user, :role).from("member").to("contributor")
    end

    it "notifies the contributor via email" do
      accept!
      expect(ContributorApplicationMailer).to have_received(:application_accepted)
      expect(mail).to have_received(:deliver_now)
    end

    context "when the user has admin permissions" do
      let(:user) { create(:user, role: :admin) }


      it "does not revoke their admin permissions" do
        expect { accept! }.not_to change(user, :role).from("admin")
      end
    end

    context "when the application was already accepted" do
      let(:status) { :accepted }

      it "raises the expected error" do
        expect { accept! }.to raise_error(
          described_class::NonpendingApplicationError,
          "ContributorApplication has already been accepted"
        )
      end
    end

    context "when the application was already declined" do
      let(:status) { :declined }

      it "raises the expected error" do
        expect { accept! }.to raise_error(
          described_class::NonpendingApplicationError,
          "ContributorApplication has already been declined"
        )
      end
    end
  end

  describe "decline!" do
    subject(:decline!) { instance.decline! }

    let(:mail) { instance_double(ActionMailer::Parameterized::MessageDelivery) }

    before do
      allow(ContributorApplicationMailer).to receive(:application_declined).with(instance).and_return(mail)
      allow(mail).to receive(:deliver_now)
    end

    it "changes the application status to declined" do
      expect { decline! }.to change(instance, :status).from("pending").to("declined")
    end

    it "does not change the user's permissions" do
      expect { decline! }.not_to change(user, :role).from("member")
    end

    it "notifies the contributor via email" do
      decline!
      expect(ContributorApplicationMailer).to have_received(:application_declined)
      expect(mail).to have_received(:deliver_now)
    end

    context "when the application was already accepted" do
      let(:status) { :accepted }

      it "raises the expected error" do
        expect { decline! }.to raise_error(
          described_class::NonpendingApplicationError,
          "ContributorApplication has already been accepted"
        )
      end
    end

    context "when the application was already declined" do
      let(:status) { :declined }

      it "raises the expected error" do
        expect { decline! }.to raise_error(
          described_class::NonpendingApplicationError,
          "ContributorApplication has already been declined"
        )
      end
    end
  end
end
