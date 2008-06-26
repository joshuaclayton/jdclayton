ActionController::Routing::Routes.draw do |map|
  map.root :controller => "home"
  map.exceptions 'logged_exceptions/:action/:id', :controller => 'logged_exceptions', :action => 'index', :id => nil
end
