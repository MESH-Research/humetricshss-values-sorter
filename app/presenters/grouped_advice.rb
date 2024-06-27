# frozen_string_literal: true

class GroupedAdvice
  def initialize(advice, outer_category:)
    inner_category = inner_category_from(outer_category)
    @advice_groups = advice.group_by(&outer_category)
                           .transform_values { |outer_category_advice| outer_category_advice.group_by(&inner_category) }
  end

  def inner_category_from(outer_category)
    if outer_category == :activity
      :value
    else
      :activity
    end
  end

  def outer_categories
    @advice_groups.keys
  end

  def inner_categories_for(outer_category)
    @advice_groups[outer_category]&.keys || []
  end

  def advice_for(outer_category, inner_category)
    @advice_groups.dig(outer_category, inner_category) || []
  end
end
