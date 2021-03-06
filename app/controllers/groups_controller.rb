class GroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_ownership, :only => [:destroy, :update, :edit, :remove_user_from_group]
  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
    @users = User.search(params[:search]).order("name asc").page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(params[:group])
    @group.users << current_user
    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find(params[:id])
    if !@group.pages.empty? 
      flash[:error] = "You can't destroy this group, it has pages associated with it."
      redirect_to groups_url
    else
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end
  end

  def remove_user_from_group 
    @group = Group.find(params[:id])
    @user = User.find(params[:user])
    Membership.find_by_user_id(params[:user]).destroy 
    redirect_to :back
  end

    private
  def check_ownership
    @group = Group.find(params[:id])
    unless current_user.groups.include?(@group) || current_user.admin?
      flash[:error] = "You do not belong to this group"
        redirect_to groups
      end
    end

end
