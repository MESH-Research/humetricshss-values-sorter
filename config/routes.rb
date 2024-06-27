# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
             only: %i[sessions passwords registrations omniauth_callbacks],
             controllers: { registrations: "users/registrations", omniauth_callbacks: "users/omniauth_callbacks" }

  delete "/welcome_modal", to: "modal#delete"

  ActiveAdmin.routes(self)

  root "static#landing"

  get "code_of_conduct", to: "static#code_of_conduct"

  # TRICKY: In AdviceController the Library used by default is Library.main, so we can use this routing scheme to show
  # the main Library simply by ensuring library_id does not exist as a param (i.e. by excluding it from the path)
  #
  # TODO: this is no longer necessary - clean up references, and remove
  get "/advice", to: "advice#index", as: "main_library_advice_index"
  get "/advice/:id", to: "advice#show", as: "main_library_advice"

  resources :libraries, only: %i[index show edit] do
    resources :advice, only: %i[index show new create edit update destroy] do
      resources :advice_submissions, only: %i[new create]
    end
    resources :activities, only: %i[new create edit update destroy]
    resources :values, only: %i[new create edit update destroy]
    resources :library_guests, only: %i[new destroy]
    get "join/:sharing_code", to: "library_guests#join", as: "join"
  end

  resources :contributor_applications, only: %i[show new create]
end
