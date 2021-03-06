class UsersController < ApplicationController

  before_filter :authenticate, :only => [:edit, :update, :show, :destroy]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_rights, :only => [:destroy]

  def new
    if !signed_in?
      @user = User.new
      @title = 'Sign up'
    else
      redirect_to(root_path)
    end
  end

  def create
    if !signed_in?
      @user = User.new(params[:user])
      if @user.save
        flash[:success] = "Welcome, #{@user.name}!"
        sign_in @user
        redirect_to @user
      else
        @title = "Please try to Sign up again"
        @user.password = ''
        @user.password_confirmation = ''
        render :new
      end
    else
      redirect_to(root_path)
    end
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end

  def edit
    @title = "Edit your profile"
  end

  def update
      if @user.update_attributes(params[:user])
        flash[:success] = "Your profile was updated, #{@user.name}!"
        redirect_to @user
      else
        flash.now[:error] = "Your changes could not be saved!"
        @user.password = ''
        @user.password_confirmation = ''
        render :edit
      end
  end

  def index
    @users = User.paginate(:page => params[:page])
    @title = "All users"
  end

  def destroy    # only for admins
    @user = User.find(params[:id])
    @user.destroy
    flash[:success] = "User deleted."
    redirect_to users_path
  end


  private

    def admin_rights
      redirect_to(root_path) unless current_user.admin?
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user == @user # || current_user.admin?      # && signed_in? optional, wegen before_filer authenticate
    end

end

