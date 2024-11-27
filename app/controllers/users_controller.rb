class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit_profile, :update_profile]

  def profile
    @user = current_user
  end

  def edit_profile
  end

  def update_profile
    if params[:user][:password].present?
      if @user.update_with_password(user_params_with_password)
        bypass_sign_in(@user)
        redirect_to profile_users_path, notice: 'Perfil actualizado exitosamente.'
      else
        render :edit_profile, status: :unprocessable_entity
      end
    else
      if @user.update(user_params)
        redirect_to profile_users_path, notice: 'Perfil actualizado exitosamente.'
      else
        render :edit_profile, status: :unprocessable_entity
      end
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name)
  end

  def user_params_with_password
    params.require(:user).permit(
      :email, 
      :first_name, 
      :last_name, 
      :current_password,
      :password,
      :password_confirmation
    )
  end
end
