class UsersController < ApplicationController
  before_action :load_user, except: %i(index new create)
  before_action :logged_in_user, except: %i(new create show)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate page: params[:page], per_page: Settings.user.per_pag
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".check_email"
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @microposts = @user.microposts.paginate page: params[:page],
      per_page: Settings.micropost.per_pag
  end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t ".profile_update"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t ".message_success"
    else
      flash[:danger] = t ".message_error"
    end
    redirect_to users_path
  end

  def following
    @title = t ".title"
    @users = @user.following.paginate(page: params[:page])
    render :show_follow
  end

  def followers
    @title = t ".title"
    @users = @user.followers.paginate(page: params[:page])
    render :show_follow
  end

  private

  def load_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t "users.load_user.error_message"
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end
end
