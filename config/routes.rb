# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
match "projects/:project_id/pages/:tab" => "project_tabs#show"
match "products/:project_id" => "project_tabs#show"

resources :cms_menus
resources :pages
resources :parts
resources :pages_parts

match "pages/:project_id/:id" => "pages#show", :via => :get

match "pages/:page_id/add_part" => "pages_parts#add", :via => :post
match "pages/:page_id/delete_part/:part_id" => "pages_parts#delete", :via => :delete
match "pages/:page_id/update/:part_id" => "pages_parts#update", :via => :put

root :to => 'pages#home', :as => 'home'
