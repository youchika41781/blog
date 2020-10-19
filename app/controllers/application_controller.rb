class ApplicationController < ActionController::Base
    before_action :set_current_user

    def set_current_user
       @current_user = User.find_by(id: session[:user_id])
    end
    
    def authenticate_user
       if @current_user == nil
          flash[:notice] = "ログインが必要です！"
          redirect_to("/blog/login")
       end
    end
    
    def forbid_login_user
        if @current_user
            flash[:notice] = "既にログインしています！"
            redirect_to("/blog/index")
        end
    end
    
    def ensure_correct_user
       if @current_user.id != params[:id].to_i
           flash[:notice] = "権限がありません！"
           redirect_to("/blog/index")
       end
    end
    
end
