# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupedAdvice do
  subject(:instance) { described_class.new(advice, outer_category: outer_category_sym) }

  let(:outer_category_sym) { :activity }
  let(:advice) { advice_list.order(:text).all }

  let(:used_activity) { create(:activity) }
  let(:another_used_activity) { create(:activity) }
  let(:rarely_used_activity) { create(:activity) }
  let(:unused_activity) { create(:activity) }

  let(:used_value) { create(:value) }
  let(:another_used_value) { create(:value) }
  let(:rarely_used_value) { create(:value) }
  let(:unused_value) { create(:value) }

  let(:advice_list) { Advice.where(id: advice_list_ids) }
  let(:advice_list_ids) { [advice1, advice2, advice3, advice4, advice5, advice6].map(&:id) }

  let!(:advice1) { create(:advice, activity: used_activity, value: used_value, text: "A good piece of advice") }
  let!(:advice2) { create(:advice, activity: used_activity, value: another_used_value, text: "But this advice might be better") }
  let!(:advice3) { create(:advice, activity: another_used_activity, value: used_value, text: "Can this advice be topped?") }
  let!(:advice4) { create(:advice, activity: another_used_activity, value: another_used_value, text: "Don't count on it") }
  let!(:advice5) { create(:advice, activity: another_used_activity, value: rarely_used_value, text: "Expect these ones not to show up") }
  let!(:advice6) { create(:advice, activity: rarely_used_activity, value: another_used_value, text: "For we use them only to make sure they don't") }
  let!(:advice7) { create(:advice, activity: rarely_used_activity, value: another_used_value, text: "This one is not included in the scope") }

  describe "#outer_categories" do
    subject(:outer_categories) { instance.outer_categories }

    context "when the outer category is :activity" do
      let(:outer_category_sym) { :activity }

      it "returns the expected outer_categories" do
        expect(outer_categories).to eq [ used_activity, another_used_activity, rarely_used_activity ]
      end
    end

    context "when the outer category is :value" do
      let(:outer_category_sym) { :value }

      it "returns the expected outer_categories" do
        expect(outer_categories).to eq [ used_value, another_used_value, rarely_used_value ]
      end
    end
  end

  describe "#inner_categories_for" do
    subject(:inner_categories_for) { instance.inner_categories_for(outer_category) }

    let(:outer_category) { nil }

    context "when the outer category is :activity" do
      let(:outer_category_sym) { :activity }
      let(:outer_category) { used_activity }

      it "returns the expected inner_categories" do
        expect(inner_categories_for).to eq [ used_value, another_used_value ]
        expect(inner_categories_for).not_to include rarely_used_value
      end

      context "when the given category has no data " do
        let(:outer_category) { unused_activity }

        it { is_expected.to eq [] }
      end
    end

    context "when the outer category is :value" do
      let(:outer_category_sym) { :value }
      let(:outer_category) { used_value }

      it "returns the expected inner_categories" do
        expect(inner_categories_for).to eq [ used_activity, another_used_activity ]
        expect(inner_categories_for).not_to include rarely_used_activity
      end

      context "when the given category has no data " do
        let(:outer_category) { unused_value }

        it { is_expected.to eq [] }
      end
    end
  end

  describe "#advice_for" do
    subject(:advice_for) { instance.advice_for(outer_category, inner_category) }

    let(:outer_category) { nil }
    let(:inner_category) { nil }

    context "when the outer category is :activity" do
      let(:outer_category_sym) { :activity }
      let(:outer_category) { used_activity }
      let(:inner_category) { used_value }

      it "returns the expected advice" do
        expect(advice_for).to eq [ advice1 ]
        expect(advice_for).not_to include(advice2, advice3, advice4, advice5, advice6)
      end

      context "when the given category has no data " do
        let(:inner_category) { unused_value }

        it { is_expected.to eq [] }
      end
    end

    context "when the outer category is :value" do
      let(:outer_category_sym) { :value }
      let(:outer_category) { used_value }
      let(:inner_category) { used_activity }

      it "returns the expected advice" do
        expect(advice_for).to eq [ advice1 ]
        expect(advice_for).not_to include(advice2, advice3, advice4, advice5, advice6)
      end

      context "when the given category has no data " do
        let(:inner_category) { unused_activity }

        it { is_expected.to eq [] }
      end
    end
  end
end
