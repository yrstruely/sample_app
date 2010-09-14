module SessionsHelper
  def sign_in(user)
    session[:session_token] = [user.id]
    @current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_session_token
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    cookies.delete(:_sample_app_session)
    self.current_user = nil
  end

  private

  def user_from_session_token
    User.find_by_id(session[:session_token])
  end

end
