# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionLoggable
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '8230f0c5bfff1ff21ba21a229c1106c1'
  
  BLUEPRINT_CONTENT_WIDTH = 24

  before_filter :manage_page_title
  
  def manage_page_title
    @page_title = ["jdclayton.com"]
  end
end
