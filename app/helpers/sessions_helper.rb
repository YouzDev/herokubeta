module SessionsHelper
# je traduis de rails a php la méthode log_in $user_id = $_SESSION[user_id]
def log_in(user)
	session[:user_id] = user.id
end
    # Se souvient d'un user dans une session longue
    def remember(user)
    	user.remember
    	cookies.permanent.signed[:user_id] = user.id
    	cookies.permanent[:remember_token] = user.remember_token
    end
# Retourne l'utilisateur qui correspond au token cookie
def current_user
	if (user_id = session[:user_id])
		@current_user ||= User.find_by(id: user_id)

		user = User.find_by(id: user_id)
    if user && user.authenticated?(:remember, cookies[:remember_token])
     log_in user
     @current_user = user
   end
 end
 return @current_user
end

def logged_in?
	!current_user.blank?
end
  # Déconnecte l'utilisateur actuel, détruit la session
  def log_out
  	session.delete(:user_id)
  	@current_user = nil
  end
    # Delete les cookies, "oublie" l'utilisateur 
    def forget(user)
      user.forget
      cookies.delete(:user_id)
      cookies.delete(:remember_token)
    end

  # Déconnecte l'utilisateur courant 
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  # Retourne true si l'utilisateur donné est celui qui est courant
  def current_user?(user)
    user == current_user
  end
  # Redirige a l'endroit stocké
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stock l'url a laquelle il a essayer d'acceder.
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

end
