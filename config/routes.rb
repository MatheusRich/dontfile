# frozen_string_literal: true

Rails.application.routes.draw do
  root 'pages#index'

  get '/:url', to: 'pages#show', as: :page
  patch '/:url', to: 'pages#update', as: :update_page

  scope module: :page do
    get '/:url/file', to: 'files#show', as: :page_file
    post '/:url/file', to: 'files#create_or_update', as: :create_page_file
    patch '/:url/file', to: 'files#create_or_update', as: :update_page_file
    delete '/:url/file', to: 'files#delete', as: :delete_page_file
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
