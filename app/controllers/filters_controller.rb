class FiltersController < ApplicationController

	def modal
		@categories = Category.all_cached
		@sources = Source.all_cached
		render layout: false
	end

	def set_filters
		if (params[:sources] && !params[:sources].empty?) || params[:reset]
			new_filters = {
				'sources' => params[:reset] ? Source.all_cached.collect{|s| s.id.to_s} : params[:sources].split(',')
			}

			if current_user
				current_user.filter.update_attribute(:data, new_filters)
			else
				session['filters'] = new_filters
			end
		end

		render plain: 'done'
	end

end
