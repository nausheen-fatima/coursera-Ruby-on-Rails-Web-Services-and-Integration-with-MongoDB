Rails.application.routes.draw do
    # resources :races
    # resources :racers do
    #     post "entries" => "racers#create_entry"
    # end
    namespace :api do
        resources :races do
            resources :results
        end
        resources :racers do
            resources :entries
        end
    end
end
