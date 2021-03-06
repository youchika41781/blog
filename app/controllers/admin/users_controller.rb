class Admin::UsersController < ApplicationController

before_action :admin_user_access, {only: [:index, :delete, :destroy]}
before_action :forbid_admin_login_user, {only: [:login_form, :login]}
  
  layout "admin"
  
  #ログイン画面
  def login_form
  end

  #ログイン処理
  def login
    @user = User.find_by!(email: params[:email])
    if @user && @user&.authenticate(params[:password])
      session[:user_id] = @user.id
      session[:admin] = @user.admin
      flash[:notice] = "ログインしました！"
      redirect_to("/admin/index")
    else
      @error_message = "メールアドレスまたはパスワードが間違っています!"
      @email = params[:email]
      @password = params[:password]
      render("admin/users/login_form")
    end
  end
  
  #ログアウト処理
  def logout
    session[:user_id] = nil
    session[:admin] = nil
      flash[:notice] = "ログアウトしました！"
    redirect_to("/admin/login")
  end
  
  #ユーザー一覧
  def index
    @users = User.all.order(created_at: "ASC").page(params[:page]).per(10)
  end
  
  #ユーザー削除
  def delete
    @user = User.find_by(id: params[:id])
    @posts = Post.where(user_id: @user.id).page(params[:page]).per(10)
  end
  
  #ユーザー削除処理
  def destroy
    @user = User.find_by(id: params[:id])
    @posts = Post.where(user_id: @user.id)
    @posts.destroy_all
    @user.destroy
    flash[:alert] = "ユーザーを削除しました！"
    redirect_to("/admin/index")
  end
  
  private
    #管理者パラメータ
    def admin_user_params
      params.permit :utf8, :authenticity_token, :password, :commit
    end
    
    #管理者アクセス制限
    def admin_user_access
      if  !@current_user || @current_user&.admin == false
        redirect_to("/blogs")
        flash[:alert] = "権限がありません！"
      end
    end
    
  #ログイン済み確認
    def forbid_admin_login_user
        if @current_user&.admin == true
            flash[:alert] = "既にログインしています！"
            redirect_to("/admin/index")
        elsif  @current_user&.admin == false
            redirect_to("/blogs")
            flash[:alert] = "既にログインしています！"
        end
    end
end
