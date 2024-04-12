class NoncesController < ApplicationController
  before_action :set_user, only: :show

  def show
    authorize :nonce
  end

  private

  def set_user
    @user = User.find_or_create_by(meta_mask_address: params[:id]) do |user|
      user.meta_mask_nonce = User.generate_new_nonce
    end
  end
end
