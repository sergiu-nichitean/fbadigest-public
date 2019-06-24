class MiscMailer < ApplicationMailer
	default from: 'admin@fbadigest.com'
 
  def new_user_email
    @user_params = params[:user]
    mail(to: 'sergiu.nichitean@gmail.com', from: %(FBA Digest <admin@fbadigest.com>), subject: "New user signed up on FBA Digest")
  end
end
