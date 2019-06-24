class MainSiteController < ApplicationController
	include ControllerSecurity

	before_action :only_admin, only: [:test_web_push_message, :submit_web_push]

  def home
    init_posts_and_filters
    
    if current_user
      current_user.update(last_visit: Time.now)
    end

  	@decoded_vapid_public_key = Base64.urlsafe_decode64(Rails.configuration.vapid['public_key']).bytes

  	if current_user && current_user.webpush_subscriptions.select{|s| s.user_agent == request.user_agent}.empty?
  		@force_notification_subscribe = true
  	end
  end

  def load_posts
    init_posts_and_filters
		render layout: nil
  end

  def saved_posts
    if current_user
      @posts = current_user.get_saved_posts
      if @posts.empty?
        redirect_to '/'
        return
      end
    else
      redirect_to '/'
      return
    end
  end

  def update_last_visit
    if current_user
      current_user.update(last_visit: Time.now)
    end
  end

  def web_push_subscribe
  	if params[:subscription]
  		check = WebpushSubscription.where(p256dh: params[:subscription][:keys][:p256dh]).first

  		if check
  			if current_user
  				check.update(user_id: current_user.id, user_agent: request.user_agent)
  				render plain: 'updated existing subscription with user data'
  			else
  				render plain: 'subscription exists, did nothing'
  			end
  		else
	  		WebpushSubscription.create(
	  			endpoint: params[:subscription][:endpoint],
		    	p256dh: params[:subscription][:keys][:p256dh],
		    	auth: params[:subscription][:keys][:auth],
		    	user_agent: request.user_agent,
		    	user_id: current_user ? current_user.id : nil
				)
				render plain: 'created new subscription'
  		end
  	end
  end

  def test_web_push_message
  end

  def submit_web_push
  	subscriptions = WebpushSubscription.all

  	subscriptions.each do |subscription|
  		begin
			  Webpush.payload_send(
			    message: params[:message],
			    endpoint: subscription.endpoint,
			    p256dh: subscription.p256dh,
			    auth: subscription.auth,
			    ttl: 24 * 60 * 60,
			    vapid: {
			      subject: 'mailto:admin@fbadigest.com',
			      public_key: Rails.configuration.vapid['public_key'],
			      private_key: Rails.configuration.vapid['private_key']
			    }
			  )
			rescue
				subscription.destroy
			end
  	end
  end

  def xml_sitemap
  	@posts = Post.where('slug IS NOT NULL').all
  end

  private

  def init_posts_and_filters
    posts_per_page = Rails.configuration.constants['posts_per_page']

    search_string = nil
    if params[:search_string]
      search_string = params[:search_string].gsub('+', ' ')
      @posts = Post.search_cached @selected_filters['sources'], search_string, posts_per_page, (params[:page] || 1)
      @all_results_count = Post.all_results_cached @selected_filters['sources'], search_string
    else
      @posts = Post.load_cached @selected_filters['sources'], posts_per_page, (params[:page] || 1)
    end

    if (params[:page] || 1).to_i == 1
      if @selected_filters['sources'].size == 1
        selected_source = Source.find(@selected_filters['sources'].first)
        @isolated_filter = "<strong>#{selected_source.name}</strong>".html_safe
      else
        Category.all_cached.each do |cat|
          if cat.sources.collect{|s| s.id} == @selected_filters['sources'].collect{|s| s.to_i}
            @isolated_filter = "the <strong>#{cat.name}</strong> category".html_safe
          end
        end
      end

      @search_string = search_string
    end
  end
end
