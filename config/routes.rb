DuelAllDay::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root 'home#index'
  get 'maintenance', to: redirect('/maintenance.html')
  get 'info' => "home#info"
  get "help" => "home#help"
  get 'leaderboard' => 'home#leaderboard'
  get "wallet" =>  "wallets#show"

  #devise_for :users, skip: [:sessions, :registrations]
  devise_for :users, :controllers => {registrations: 'registrations', sessions: 'sessions'}


  # as :user do
  #   get 'signin' => 'sessions#new', :as => :new_user_session
  #   post 'signin' => 'sessions#create', :as => :user_session
  #   match 'logout' => 'sessions#destroy', :as => :destroy_user_session,
  #     :via => Devise.mappings[:user].sign_out_via
  #
  #   get 'signup' => "registrations#new", as: :new_user_registration
  #   post 'signup' => 'registrations#create', as: :user_registration
  #   get 'edit_profile' => 'registrations#edit', as: :edit_user_registration
  #   match 'edit_profile' => 'registrations#update', via: [:patch, :put], as: ''
  # end

  get "terms", to: "home#terms", as: :terms_of_service
  #get "wallet", to: "wallets#show"

  resources "tickets", only: [:create, :index] do
    member do 
      get 'cancel'
      get 'accept'
      get 'report'
    end
  end

  get "deposit"  => "tickets#new_deposit"
  get "withdraw" => "tickets#new_withdraw"
  get "transfer" => "tickets#new_transfer"

  resources "chat_messages", only: [:create]
  resources "chats", only: [:show, :create, :index]

  resources :dice_games, only: [:show, :new, :create, :index] do 
    member do 
      get "join"
      get "leave"
      get "roll"
    end
  end

  resources :flower_games, except: [:edit, :destroy, :update] do 
    member do 
      patch 'complete'
      get 'cancel'
      get 'accept'
    end
  end

  resources :flower_game_hosts, only: [:create, :update] do 
    member do 
      get "go_offline"
      get 'open_chat'
      get 'test_stream'
    end
  end
end
