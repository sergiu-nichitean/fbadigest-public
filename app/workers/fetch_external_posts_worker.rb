class FetchExternalPostsWorker
  
  def perform(silent = false)
  	new_posts = []
    new_posts += Post.fetch_blogosphere
    new_posts += Post.fetch_news_sites
    new_posts += Post.fetch_amazon_official

    puts "#{new_posts.count} new posts in total"

    if !new_posts.empty? && !silent
    	Rails.cache.delete('posts')

	  	subscriptions = WebpushSubscription.all

	  	subscriptions.each do |subscription|
	  		my_new_posts = new_posts.clone
	  		puts "new_posts.count = #{new_posts.count}"
	  		puts "my_new_posts.count = #{my_new_posts.count}"

	  		if subscription.user
	  			# first do filters
	  			puts "User ID #{subscription.user_id} has filters: #{subscription.user.filter.data['sources'].join(',')}"
	  			my_new_posts.select!{|p| subscription.user.filter.data['sources'].include? p[:source_id].to_s}
	  			puts "Updated post count: #{my_new_posts.count}"

	  			# then notification settings
	  			puts "User ID #{subscription.user_id} has config: #{subscription.user.filter.data['sources'].join(',')}"
	  			my_new_posts.select!{|p| subscription.user.get_notification_sources.include? p[:source_id]}
	  			puts "Updated post count: #{my_new_posts.count}"
	  		end

	  		unless my_new_posts.empty?
		    	if my_new_posts.count == 1
		    		push_title = "New post from #{my_new_posts[0][:source]}"
		    		push_body = "#{my_new_posts[0][:title]}"
		    	else
		    		push_title = "#{my_new_posts.count} new posts"
		    		push_body = "From #{my_new_posts.collect{|p| p[:source]}.uniq.join(', ')}"
		    	end

				  puts "sending Web push to: #{subscription.user_agent} (User ID: #{subscription.user_id})"
				  
				  message = {
					  title: push_title,
					  body: push_body
					}

					begin
					  Webpush.payload_send(
					    message: message.to_json,
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
					rescue => e
						puts "RESCUE: #{e.message}"
						puts "destroying subscription"
						subscription.destroy
					end
				end
	  	end
    end
  end

end