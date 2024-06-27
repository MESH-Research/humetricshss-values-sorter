# frozen_string_literal: true

require "rails_helper"

RSpec.describe Value, type: :model do
  subject(:instance) { create(:value, library: library, name: name, icon_class: icon_class) }

  let(:library) { Library.main }
  let(:name) { "Equity" }
  let(:icon_class) { "fas fa-balance-scale" }

  describe "associations" do
    describe "#advice" do
      subject(:advice) { instance.advice }

      let!(:instance_advice) { create_list(:advice, 3, library: library, value: instance) }
      let!(:other_advice) { create(:advice) }

      it "contains only the Value's associated advice" do
        expect(advice).to contain_exactly(*instance_advice)
      end

      it "keeps the Value from being destroyed when nonempty" do
        expect { instance.advice.destroy_all }.to change(instance, :destroy).from(false).to(instance)
      end
    end
  end

  describe "validations" do
    subject(:instance) { described_class.new(library: library, name: name, icon_class: icon_class) }

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

    describe "#name" do
      context "when absent" do
        let(:name) { nil }

        it "fails validation" do
          expect(instance).not_to be_valid
          expect(instance.errors.messages_for(:name)).to contain_exactly("can't be blank")
        end
      end

      context "when present" do
        let(:name) { "Equity" }

        it { is_expected.to be_valid }
      end
    end
  end
end
