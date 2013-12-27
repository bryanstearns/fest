Fest::Application.routes.draw do
  # Authentication stuff
  devise_for :users

  # Public stuff
  resources :festivals, only: [:index, :show] do
    post :reset_rankings, on: :member
    post(:random_priorities, on: :member) if !Rails.env.production?
    post :reset_screenings, on: :member
    resource :subscription, path: 'assistant', controller: :subscriptions,
             only: [:show, :update]
    match 'priorities' => "picks#index"
  end
  resources :films, only: [] do
    resources :picks, only: [:create]
  end
  resources :screenings, only: [:show]
  match 'ratings/:token' => 'user_ratings#show', as: :user_ratings

  resources :announcements, only: [:index, :show]
  resources :questions, only: [:new, :create]

  root to: "home#landing"
  match 'changes' => "home#changes", as: :changes
  match 'feedback' => "questions#new", as: :feedback
  match 'help' => "home#help", as: :help
  match 'maintenance' => "home#maintenance", as: :maintenance
  match 'sign_ups_off' => "home#sign_ups_off", as: :sign_ups_off
  match 'welcome' => "home#index", as: :welcome

  # Admin stuff
  match 'admin' => "home#admin", as: :admin_root
  namespace 'admin' do
    resources :festivals, only: [:new, :create, :edit, :update, :destroy] do
      resources :films, only: [:index, :new, :create]
    end
    resources :films, only: [:show, :edit, :update, :destroy] do
      resources :screenings, only: [:new, :create]
    end
    resources :screenings, only: [:edit, :update, :destroy]

    resources :locations do
      resources :venues, only: [:new, :create]
    end
    resources :venues, only: [:edit, :update, :destroy]

    resources :users do
      post :act_as, on: :member
    end
    resources :enabled_flags, :only => [:update]
    resources :announcements, only: [:new, :create, :edit, :update, :destroy]
    resources :questions, only: [:index, :show, :edit, :update, :destroy]
  end
end
