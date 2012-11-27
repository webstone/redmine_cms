# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
match "projects/:project_id/pages/:tab" => "project_tabs#show"
match "products/:project_id" => "project_tabs#show"

resources :cms_menus
resources :pages

match "pages/:project_id/:id" => "pages#show", :via => :get

root :to => 'pages#home', :as => 'home'
