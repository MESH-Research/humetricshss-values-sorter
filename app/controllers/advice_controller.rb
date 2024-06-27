# frozen_string_literal: true

class AdviceController < ApplicationController
  include AdviceHelper

  before_action :set_index_params, only: %i[index show]
  before_action :set_library
  before_action :set_activities, :set_values, except: %i[show]
  before_action :build_advice, only: %i[new create]
  before_action :set_advice, only: %i[edit update destroy]

  def index
    @categories = ADVICE_CATEGORIES
    @advice = filtered_advice(library_advice.published, **@index_params.slice(:search_term, :activity_ids, :value_ids).to_h.symbolize_keys)
    @grouped_advice = GroupedAdvice.new(@advice, outer_category: @index_params[:outer_category].to_sym)
  end

  def show
    @advice = authorize library_advice.published.includes(:activity, :value).with_rich_text_details_and_embeds.find(params[:id])
  end

  def new
  end

  def create
    if @advice.save
      redirect_to edit_library_path(@library)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @advice.update(advice_params)
      redirect_to edit_library_path(@library)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @advice.destroy
      redirect_to edit_library_path(@library)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_index_params
    @index_params = advice_filter_params(params)
  end

  def set_library
    @library = if params[:library_id].present?
      policy_scope(Library).find(params[:library_id])
    else
      Library.main
    end
  end

  def set_activities
    @activities = policy_scope(Activity).where(library: @library).order(:name)
  end

  def set_values
    @values = policy_scope(Value).where(library: @library).order(:name)
  end

  def build_advice
    @advice = authorize @library.advice.build(advice_params)
  end

  def set_advice
    @advice = authorize library_advice.includes(:activity, :value).with_rich_text_details_and_embeds.find(params[:id])
  end

  def library_advice
    policy_scope(Advice).where(library: @library)
  end

  def advice_params
    advice_params = params.fetch(:advice, {}).permit(:activity, :value, :text, :details, :published_state).to_h
    advice_params[:activity] = @activities.find_by(id: advice_params[:activity])
    advice_params[:value] = @values.find_by(id: advice_params[:value])
    advice_params
  end
end
