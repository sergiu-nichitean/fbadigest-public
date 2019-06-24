class ContactMailer < ApplicationMailer
	default from: 'contact@fbadigest.com'
 
  def contact_email
    @contact_params = params[:contact]
    headers['Reply-To'] = %("#{@contact_params[:first_name]} #{@contact_params[:last_name]}" <#{@contact_params[:email]}>)
    mail(to: 'sergiu.nichitean@gmail.com', from: %("#{@contact_params[:first_name]} #{@contact_params[:last_name]}" <contact@fbadigest.com>), subject: "#{@contact_params[:first_name]} #{@contact_params[:last_name]} has a message from the FBA Digest contact form")
  end
end
