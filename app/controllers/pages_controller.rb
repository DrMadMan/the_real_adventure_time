class PagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :graph]
  before_filter :check_ownership, :only => [:edit, :update, :destroy]
  before_filter :check_branch_access, :only => [:new]
  # GET /pages
  # GET /pages.json

  def index
    if params[:term]
      @pages = Page.search(params[:term])
    else
      @search = Page.search(params[:search]).find_with_reputation(:votes, :all, { :order => 'votes DESC' })
      @pages =  Kaminari.paginate_array(@search).page(params[:page])
    end

    if params[:user] 
      @pages = User.find(params[:user]).pages.page(params[:page])
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @pages }
    end
  end

  def vote
    value = params[:type] == "up" ? 1 : -1
    @page = Page.find(params[:id])
    @page.add_or_update_evaluation(:votes, value, current_user)
    redirect_to :back, notice: "Thank you for voting!"
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = Page.find(params[:id])
    @pages = Page.find(params[:id]).pages

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @page }
    end
  end

  def graph
    @pages = Page.all
    @paths = Path.all
    
    @nodes = @pages.map do |page|{
      :rating => page.reputation_for(:votes),
      :id => page.id,
      :name => page.title,
      :group => 1,      
      :color => page.color
    }
  end

  @node_helper = Array.new


  @nodes.each do |node| 
    @node_helper << node[:id]
  end

  @links = @paths.map do |path|{
    :source => @node_helper.index(path.page_from_id),
    :target => @node_helper.index(path.page_to_id),
    :value => path.id
  }
end
respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => {
        :nodes => @nodes,
        :links => @links
      }

    }
  end
end


  # GET /pages/new
  # GET /pages/new.json
  def new
    @page = Page.new
    if(params.has_key?(:root_id)) 
      @root = Page.find(params[:root_id])
      @page.paths.build()
      respond_to do |format|
            format.html # new.html.erb
            format.json { render :json => @page }
          end
        else 
          respond_to do |format|
          format.html # new.html.erb
          format.json { render :json => @page }
        end
      end
    end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
    @pages = Page.all
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = Page.new(allowed_attributes)
    @pages = Page.all
    @page.group = Group.find(params[:group_id])
    respond_to do |format|
      if @page.save
        format.html { redirect_to @page, :notice => 'Page was successfully created.' }
        format.json { render :json => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.json { render :json => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @page = Page.find(params[:id])
    respond_to do |format|
      if @page.update_attributes(allowed_attributes)
        format.html { redirect_to @page, :notice => 'Page was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to pages_url }
      format.json { head :no_content }
    end
  end

  private

  def check_ownership
    @page = Page.find(params[:id])
    if !current_user.admin?
      unless @page.group.users.all.include? current_user 
        flash[:error] = "You do not belong to the group that owns this page. Sorry bud :("
          redirect_to @page
      end
    end
  end

  def check_branch_access
    if params.has_key?(:root_id)
      @root = Page.find(params[:root_id])
      if @root.editable == false
        if !current_user.admin?
          unless (@root.group.users.all.include?(current_user)) 
            flash[:error] = "You don't own the node page. Try creating your own node!"
            redirect_to @root
          end
        end
      end
    end
  end

  def allowed_attributes
    if current_user.admin == true
      params.require(:page).permit!
    else 
      params.require(:page).permit(:content, :stamp, :title, :paths_attributes, :group_id)
    end 
  end
end