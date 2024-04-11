class SessionsController < ApplicationController
  include IdentityVerifiable

  def new
    authorize :session
  end

  def create
    authorize :session

    user = User.find_by(meta_mask_address: session_params[:address])
    return unless user

    if valid_signature?(from: session_params[:address], signature: session_params[:signature], message: session_params[:signature_message]) &&
       valid_nonce?(user, session_params[:signature_message])
      authenticate(user)
      response = { status: :ok, redirect_to_url: root_url }
    else
      response = { status: :unauthorized }
    end

    render json: response,
           status: response[:status]
  end

  def destroy
    authorize :session

    cookies.delete(:jwt)

    redirect_to root_path
  end

  private

  def session_params
    params.require(:session).permit(
      :address,
      :signature_message,
      :signature
    )
  end
end
