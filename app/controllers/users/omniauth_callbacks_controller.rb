class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    oauth_sign_in('Facebook')
  end

  def google_oauth2
    oauth_sign_in('Google')
  end

  def failure
    redirect_to root_path
  end

  private

  def oauth_sign_in(provider_name)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    sign_in @user, event: :authentication
    set_flash_message(:notice, :success, kind: provider_name)
    render layout: nil
  end
end