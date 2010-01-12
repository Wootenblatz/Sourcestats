ActionController::Routing::Routes.draw do |map|
  map.server_show '/server/show/:id', :controller => "server", :action => "show"
  map.server_list '/server/list/:page', :controller => "server", :action => "list", :requirements => { :page => /\d+/ }
  map.player_show '/player/show/:server_id/:player_id/:page', :controller => "player", :action => "show", :requirements => { :page => /\d+/ }, :page => 1
  map.player_list '/player/list/:server_id/:page', :controller => "player", :action => "list", :requirements => { :page => /\d+/ }
  map.event_list '/event/list/:server_id/:page', :controller => "event", :action => "list", :requirements => { :page => /\d+/ }
  map.trigger_list '/trigger/list/:server_id/:page', :controller => "trigger", :action => "list", :requirements => { :page => /\d+/ }
  map.weapon_list '/weapon/list/:server_id/:page', :controller => "weapon", :action => "list", :requirements => { :page => /\d+/ }
  map.map_list '/map/list/:server_id/:page', :controller => "map", :action => "list", :requirements => { :page => /\d+/ }
  map.role_list '/role/list/:server_id/:page', :controller => "role", :action => "list", :requirements => { :page => /\d+/ }
  map.team_list '/team/list/:server_id/:page', :controller => "team", :action => "list", :requirements => { :page => /\d+/ }
  map.bot_list '/bot/list/:server_id/:page', :controller => "bot", :action => "list", :requirements => { :page => /\d+/ }
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "server", :action => "list"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
end
