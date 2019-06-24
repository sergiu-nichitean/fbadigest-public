module ControllerSecurity
	def only_admin
		unless current_user && current_user.administrator?
			redirect_to '/'
		end
	end
end