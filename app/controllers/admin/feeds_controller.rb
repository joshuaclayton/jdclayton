class FeedsController < Admin::BaseController
  before_filter :find_or_initialize_feed, :only => [:show, :new, :edit, :update, :destroy]
  
  # GET /feeds
  def index
    @feeds = Feed.find(:all)
  end

  # POST /feeds
  def create
    @feed = Feed.new(params[:feed])
    if @feed.save
      flash[:notice] = 'Feed was successfully created.'
      redirect_to(@feed)
    else
      render :action => "new"
    end
  end

  # PUT /feeds/1
  def update
    if @feed.update_attributes(params[:feed])
      flash[:notice] = 'Feed was successfully updated.'
      redirect_to(@feed)
    else
      render :action => "edit"
    end
  end

  # DELETE /feeds/1
  def destroy
    @feed.destroy
    redirect_to(feeds_url)
  end
  
  protected
  
  def find_or_initialize_feed
    @feed = params[:id] ? Feed.find(params[:id]) : Feed.new
  end
end
