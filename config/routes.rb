# frozen_string_literal: true

Rails.application.routes.draw do
  defaults format: :html do
    resources :orders, only: %i[index new create]
    root to: 'orders#new'
  end
end
