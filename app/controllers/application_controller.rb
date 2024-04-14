class ApplicationController < ActionController::Base
  include Pundit::Authorization

  helper_method :current_user

  def current_user
    @current_user = User.find_by_id(session[:current_user_id])
  end

  private

  def authenticate(user)
    return false unless user

    session[:current_user_id] = user.id
    user.regenerate_meta_mask_nonce!

    true
  end
end
