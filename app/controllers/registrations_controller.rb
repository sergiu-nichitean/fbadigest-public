class RegistrationsController < Devise::RegistrationsController  
  respond_to :json
  layout false

  after_action :send_new_user_email, only: :create
  after_action :send_welcome_email, only: :create

  protected

  def update_resource(resource, params)
  	if current_user.is_omniauth?
  		resource.update_without_password(params)
  	else
  		resource.update_with_password(params)
  	end
  end

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :newsletter_subscribed, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :newsletter_subscribed, :password, :password_confirmation, :current_password)
  end

  def send_new_user_email
    MiscMailer.with(user: params[:user]).new_user_email.deliver_now
  end

  def send_welcome_email
    UserMailer.with(user: params[:user]).welcome_email.deliver_now
  end
end