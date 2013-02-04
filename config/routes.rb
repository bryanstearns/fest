Fest::Application.routes.draw do
  # Authentication stuff
  devise_for :users

  # Public stuff
  resources :festivals, only: [:index, :show] do
    member do
      put :reset_rankings
      put :reset_screenings
    end
    resource :subscription, path: 'assistant', controller: :subscriptions,
             only: [:show, :update]
    match 'priorities' => "picks#index"
  end
  resources :films, only: [] do
    resources :picks, only: [:create]
  end
  resources :screenings, only: [:show]

  resources :questions, only: [:new, :create]

  root to: "home#landing"
  match 'welcome' => "home#index", as: :welcome
  match 'maintenance' => "home#maintenance", as: :maintenance
  match 'sign_ups_off' => "home#sign_ups_off", as: :sign_ups_off
  match 'faq' => "home#faq", as: :faq
  match 'feedback' => "questions#new", as: :feedback

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

    resources :users
    resources :enabled_flags, :only => [:update]
    resources :questions, only: [:index, :show, :edit, :update, :destroy]
  end
end
