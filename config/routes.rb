Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "users#feed"

  devise_for :users

  resources :comments, only: [:create, :edit, :update, :destroy]
  resources :follow_requests, only: [:create, :update, :destroy]
  resources :likes, only: [:create, :destroy]
  resources :photos do
    resources :comments, only: [:index]
    resources :likes, only: [:index]
  end
  resources :users, only: [ :index ]

  get ":username" => "users#show", as: :user
  get ":username/feed" => "users#feed", as: :feed
  get ":username/followers" => "users#followers", as: :followers
  get ":username/follows" => "users#follows", as: :follows
  get ":username/pending" => "users#pending", as: :pending
  get ":username/discover" => "users#discover", as: :discover
end
