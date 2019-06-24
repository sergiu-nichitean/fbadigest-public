class NotificationsController < ApplicationController
	def modal
		@categories = Category.all_cached
		@sources = Source.all_cached
		render layout: false
	end

	def set_notifications
		if params[:sources] && !params[:sources].empty?
			current_user.update_attribute(:notification_sources, params[:sources].split(',').collect{|s| s.to_i})
		end

		render plain: 'done'
	end
end
