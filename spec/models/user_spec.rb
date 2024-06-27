# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  subject(:instance) do
    described_class.new(
      first_name: first_name,
      last_name: last_name,
      email: email,
      password: password,
      role: role,
      terms_of_service: terms_of_service,
      contributor_application: contributor_application,
      library: library
    )
  end

  let(:first_name) { "bob" }
  let(:last_name) { "bobberson" }
  let(:email) { "bbobberson@example.com" }
  let(:password) { "passw0rd" }
  let(:role) { :member }
  let(:terms_of_service) { true }
  let(:contributor_application) { nil }
  let(:library) { nil }

  describe "associations" do
    subject(:instance) do
      create(
        :user,
        first_name: first_name,
        last_name: last_name,
        email: email,
        password: password,
        role: role,
        terms_of_service: terms_of_service,
        contributor_application: contributor_application,
        library: library
      )
    end

    describe "#contributor_application" do
      let(:contributor_application) { build(:contributor_application, user: nil) }

      it "is destroyed alongside the corresponding user" do
        expect { instance.destroy }.to change(contributor_application, :destroyed?).from(false).to(true)
      end
    end

    describe "#library_guests" do
      let(:library_guests) { create_list(:library_guest, 3, guest: instance) }

      it "are destroyed alongside the corresponding user" do
        library_guest_ids = library_guests.map(&:id)
        expect { instance.destroy }.to change { LibraryGuest.where(id: library_guest_ids).empty? }.from(false).to(true)
      end
    end
  end

  describe "validations" do
    it { is_expected.to be_valid }

    describe "#first_name" do
      context "when empty" do
        let(:first_name) { "" }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:first_name)).to contain_exactly("can't be blank")
        end
      end

      context "when present" do
        let(:first_name) { "bob" }

        it { is_expected.to be_valid }
      end
    end

    describe "#last_name" do
      context "when empty" do
        let(:last_name) { "" }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:last_name)).to contain_exactly("can't be blank")
        end
      end

      context "when present" do
        let(:last_name) { "bobberson" }

        it { is_expected.to be_valid }
      end
    end

    describe "#email" do
      context "when empty" do
        let(:email) { "" }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:email)).to contain_exactly("can't be blank")
        end
      end

      context "when nonconformant" do
        let(:email) { "http://not-an-email.com" }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:email)).to contain_exactly("is invalid")
        end
      end

      context "when a valid email" do
        let(:email) { "bbobberson@example.com" }

        it { is_expected.to be_valid }
      end
    end

    describe "#password" do
      context "when empty" do
        let(:password) { "" }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:password)).to contain_exactly("can't be blank")
        end
      end

      context "when too short" do
        let(:password) { "smol" }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:password)).to contain_exactly("is too short (minimum is 6 characters)")
        end
      end

      context "when a valid password" do
        let(:password) { "passw0rd" }

        it { is_expected.to be_valid }
      end
    end

    describe "#role" do
      context "when absent" do
        let(:role) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:role)).to contain_exactly("can't be blank")
        end
      end

      context "when present" do
        let(:role) { :member }

        it { is_expected.to be_valid }
      end
    end

    describe "#terms_of_service" do
      context "when nil" do
        let(:terms_of_service) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:terms_of_service)).to contain_exactly("must be accepted")
        end
      end

      context "when false" do
        let(:terms_of_service) { false }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:terms_of_service)).to contain_exactly("must be accepted")
        end
      end


      context "when true" do
        let(:terms_of_service) { true }

        it { is_expected.to be_valid }
      end
    end
  end

  describe "#full_name" do
    subject(:full_name) { instance.full_name }

    let(:first_name) { "bob" }
    let(:last_name) { "bobberson" }

    it { is_expected.to eq "bob bobberson" }
  end

  describe "#can_contribute?" do
    subject(:can_contribute?) { instance.can_contribute? }

    context "when the user is a member" do
      let(:role) { :member }

      it { is_expected.to be false }
    end

    context "when the user is a contributor" do
      let(:role) { :contributor }

      it { is_expected.to be true }
    end

    context "when the user is an admin" do
      let(:role) { :admin }

      it { is_expected.to be true }
    end
  end
end
