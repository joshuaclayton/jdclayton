class <%= controller_class_name %>Controller < ApplicationController

  def index
  end
  
  def update
    params[:settings].each do |k, v|
      Settings.send("#{k}=", v)
    end
    redirect_to :action => "index"
  end
  
end
