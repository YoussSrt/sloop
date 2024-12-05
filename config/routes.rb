Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
  # config/routes.rb

  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "profile", to: "pages#profile"
  get 'feed', to: 'pages#feed', as: 'feed'
  get 'profile/:id', to: 'pages#other_user_profile', as: 'other_user_profile'
  get 'about', to: 'pages#about', as: 'about'

  post "preferences", to: "users#update_preferences", as: :preferences
  # get "preferences", to: "users#edit_preferences", as: :edit_preferences

  # Defines the root path route ("/")
  # root "posts#index"
  resources :sloopies do
    resources :questions, only: [:index, :create]
    resources :reviews, only: [:new, :create, :edit, :update, :destroy]
    resources :steps, only: [:update]
  end

  resources :reviews, only: [:show, :edit, :update, :destroy]

  resources :chatrooms, only: [:index, :show, :create] do
    resources :messages, only: [:create]
  end

  resources :sloopies do
    post 'copy', on: :member
  member do
    patch :update_save
    patch :update_status
   end
  end

  resources :user_preferences, only: [] do
    collection do
      get :edit
    end
  end
end
