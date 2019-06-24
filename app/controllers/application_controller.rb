class ApplicationController < ActionController::Base
	before_action :load_filters, :set_meta, :new_posts_today

	def load_filters
		default_filters = {
				'sources' => Source.all_cached.collect{|s| s.id.to_s}
			}

		if current_user
			if current_user.filter
				@selected_filters = current_user.filter.data
			else
				Filter.create(user_id: current_user.id, data: default_filters)
			end
		else
			session['filters'] ||= default_filters
			@selected_filters = session['filters']
		end
	end

	def set_meta
		@meta_description = 'News aggregator for FBA and Amazon related articles from the worlds most popular blogs, podcasts and news outlets.'
		@meta_title = 'Amazon Seller News, Latest FBA Posts, Articles and Tips - FBA Digest'
		@meta_image = '/images/fba-digest.jpg'
	end

  def new_posts_today
    @new_posts_today = Post.new_posts_today
  end

	def render_not_found
  	render :file => "#{Rails.root}/public/404.html",  :status => 404
	end
end
