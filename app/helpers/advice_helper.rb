# frozen_string_literal: true

module AdviceHelper
  ADVICE_CATEGORIES = %w[activity value]

  def advice_filter_params(params)
    # TRICKY: Rails adds a blank to all array-typed params to ensure that the param is sent even when the array would
    # contain no elements. This blank element is undesirable when e.g. counting the number of ids sent back, so we
    # discard it using transform_values
    params.permit(:outer_category, :search_term, activity_ids: [], value_ids: [])
          .with_defaults(outer_category: ADVICE_CATEGORIES.first, activity_ids: [], value_ids: [])
          .transform_values { |v| v.is_a?(Array) ? v.reject(&:blank?) : v }
  end

  def filtered_advice(advice_scope, search_term: "", activity_ids: [], value_ids: [])
    advice = advice_scope.includes(:activity, :value, :rich_text_details).order(:text)
    advice = advice.where(activity_id: activity_ids) if activity_ids.any?
    advice = advice.where(value_id: value_ids) if value_ids.any?
    advice = [*advice.search_text(search_term), *advice.search_details(search_term)].uniq if !search_term.blank?

    advice
  end
end
