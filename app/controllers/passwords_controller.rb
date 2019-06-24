class PasswordsController < Devise::PasswordsController  
  respond_to :json
  layout false

  def edit
  	super
  	render layout: 'application'
  end
end