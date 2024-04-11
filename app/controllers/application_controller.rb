class ApplicationController < ActionController::Base
  include Pundit::Authorization

  helper_method :current_user

  def current_user
    @current_user ||= begin
      token ? User.from_auth_token(token) : nil
    rescue StandardError
      nil # optional but explicit
    end
  end

  private

  def authenticate(user)
    return false unless user

    user.regenerate_meta_mask_nonce!

    cookies.signed[:jwt] = {
      value: user.auth_token,
      expires: User::AUTH_TOKEN_TTL.from_now,
      httponly: true
    }
    true
  end

  def token
    cookies.signed[:jwt]
  end
end
