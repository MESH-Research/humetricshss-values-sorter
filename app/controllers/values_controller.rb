# frozen_string_literal: true

class ValuesController < ApplicationController
  before_action :set_library
  before_action :build_value, only: %i[new create]
  before_action :set_value, only: %i[edit update destroy]

  def new
  end

  def create
    if @value.save
      redirect_to edit_library_path(@library)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @value.update(value_params)
      redirect_to edit_library_path(@library)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @value.destroy
      redirect_to edit_library_path(@library)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_library
    @library = policy_scope(Library).find(params[:library_id])
  end

  def build_value
    @value = authorize @library.values.build(value_params)
  end

  def set_value
    @value = authorize library_values.find(params[:id])
  end

  def library_values
    policy_scope(Value).where(library: @library)
  end

  def value_params
    params.fetch(:value, {}).permit(:name)
  end
end
