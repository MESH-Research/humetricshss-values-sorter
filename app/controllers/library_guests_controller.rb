# frozen_string_literal: true

class LibraryGuestsController < ApplicationController
  before_action :set_library, except: :join
  before_action :authenticate_user!, :set_library_by_sharing_code, only: :join

  def new
    @library_guest = authorize @library.library_guests.build
  end

  def join
    authorize @library_guest = @library.library_guests.build(guest: current_user)

    if @library_guest.save
      flash.notice = "Successfully joined #{@library.owner.full_name}'s library"
    else
      flash.alert = @library_guest.errors.first.full_message
    end

    redirect_to library_path(@library)
  end

  def destroy
    @library_guest = authorize @library.library_guests.find(params[:id])

    @library_guest.destroy
    flash.alert = @library_guest.errors.first.full_message unless @library_guest.destroyed?
    redirect_to edit_library_path(@library)
  end


  private

  def set_library
    @library = policy_scope(Library).find(params[:library_id])
  end

  def set_library_by_sharing_code
    @library = Library.where(sharing_code: params[:sharing_code]).find(params[:library_id])
  end
end
