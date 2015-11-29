# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get "/sitemap.xml" => "welcome#sitemap", :defaults => {:format => :xml}

get "projects/:project_id/pages/:tab" => "project_tabs#show", :as => "project_tab"

resources :cms_menus
resources :cms_redirects
resources :pages do
  member do
   get :expire_cache
  end
end
resources :parts do
  member do
   get :expire_cache
  end
end
resources :pages_parts
resources :cms_variables

get "pages/:project_id/:id" => "pages#show"

post "pages/:page_id/add_part" => "pages_parts#add"
delete "pages/:page_id/delete_part/:part_id" => "pages_parts#delete"
put "pages/:page_id/update/:part_id" => "pages_parts#update"

get 'attachments/thumbnail/:id(/:size)/:filename', :controller => 'attachments', :action => 'thumbnail', :id => /\d+/, :filename => /.*/, :size => /\d+/

resources :cms_settings do 
  collection do 
    post 'save'
  end
end