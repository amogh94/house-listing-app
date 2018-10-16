Rails.application.routes.draw do
  resources :inquiries
  resources :interests

  resources :houses
  get "houses:exp", to: 'houses#search', exp: /[\+A-Za-z0-9\-_]*/
  resources :companies

  get "companies:exp", to: 'companies#search', exp: /[\+A-Za-z0-9\-]*/
  resources :users

  get "/" => "pages#show"
  post "/search" => "houses#searchbar"
  post "/searchFilter" => "houses#search_filter"
  post "/interests/h" => "interests#get_interest_users_by_house"
  post "inquiries/h" => "inquiries#get_inquiries_by_house"
  post "/session/login" => "sessions#create"
  delete "/session/logout" => "sessions#destroy"
end
