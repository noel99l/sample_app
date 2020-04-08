module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  def current_user?(user)
    user == current_user
  end
  
  # 現在ログイン中のユーザーを返す（いる場合）
  def current_user
    if (user_id = session[:user_id]) #(ユーザーIDにユーザーIDのセッションを代入した結果) ユーザーIDのセッションが存在すれば
      @current_user ||= User.find_by(id: user_id) # @current_user = @current_user || User.find_by(id: session[:user_id]) の短縮形
    elsif (user_id = cookies.signed[:user_id]) #elsif cookies.signed[:user_id] と同じ、この時点でローカル変数user_idに代入することでcookiesメソッドの使用を１回のみに留めている。
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  
  #ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end
  
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  #記載したURLにリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
  
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end