class UserMailer < ApplicationMailer
	default from: 'serge@fbadigest.com'
 
  def welcome_email
    @user_params = params[:user]
    mail(to: @user_params[:email], from: %(Serge Nikita - FBA Digest <serge@fbadigest.com>), subject: "Welcome to FBA Digest!")
  end

  def weekly_newsletter
    @user_params = params[:user]
    @newsletter_params = params[:newsletter]
    mail(to: @user_params[:email], from: %(Serge Nikita - FBA Digest <serge@fbadigest.com>), subject: @newsletter_params[:subject])
  end
end
