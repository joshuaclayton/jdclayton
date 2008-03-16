class <%= controller_class_name %>Controller < ApplicationController
  before_filter :find_<%= file_name %>, :except => [:index, :new, :create]
  
  with_options :redirect_to => { :action => :index } do |c|
    c.verify :method => :delete,  :only => :destroy
    c.verify :method => :put,     :only => :update
    c.verify :method => :post,    :only => :create
  end
  
  def index
    @<%= table_name %> = <%= class_name %>.find(:all)
  end
  
  def new
    @<%= file_name %> = <%= class_name %>.new
  end
  
  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])
    @<%= file_name %>.save!
    flash[:notice] = "<%= file_name.capitalize %> was successfully created."
    redirect_to <%= file_name %>_path(@<%= file_name %>)
  rescue ActiveRecord::RecordInvalid
    render :action => "new"
  end
  
  def show; end
  
  def edit; end
  
  def update
    @<%= file_name %>.attributes = params[:<%= file_name %>]
    @<%= file_name %>.save!
    redirect_to <%= table_name %>_path(@<%= file_name %>)
  rescue ActiveRecord::RecordInvalid
    render :action => "edit"
  end
  
  def destroy
    @<%= file_name %>.destroy
    redirect_to :action => "index"
  end
  
  protected
  
    def find_<%= file_name %>
      @<%= file_name %> = <%= class_name %>.find(params[:id])
    end
end
