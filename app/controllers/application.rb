# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class LoggedExceptionsController < ActionController::Base
  protect_from_forgery :secret => '5c4b52c75de67f83be116cc5cd5a9c0e'
end


class ApplicationController < ActionController::Base
  include ExceptionLoggable
  helper :all # include all helpers, all the time

  protect_from_forgery :secret => '8230f0c5bfff1ff21ba21a229c1106c1'
  
  BLUEPRINT_CONTENT_WIDTH = 24 unless defined? BLUEPRINT_CONTENT_WIDTH

  before_filter :manage_page_title
  
  def manage_page_title
    @page_title = ["jdclayton.com"]
  end
end
