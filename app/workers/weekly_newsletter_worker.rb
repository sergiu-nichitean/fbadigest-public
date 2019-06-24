class WeeklyNewsletterWorker
  
  def perform
  	most_read_articles = Post.where('published BETWEEN ? AND ?', 1.week.before, Time.now.utc).order(views: :desc).limit(3)
  	most_read_articles = most_read_articles.collect{|p| p}

  	unless most_read_articles.collect{|p| p.category_id}.include?(2)
  		most_read_blogosphere_article = Post.where('category_id = 2 AND published BETWEEN ? AND ?', 1.week.before, Time.now.utc).order(views: :desc).first
  		if most_read_blogosphere_article
  			new_most_read_articles = [
  				most_read_blogosphere_article,
  				most_read_articles[0],
  				most_read_articles[1]
  			]
  			most_read_articles = new_most_read_articles
  		end
  	end

  	User.where('newsletter_subscribed = 1').each do |u| # TODO: send to all users when ready
  		puts "Sending for user with ID #{u.id}"
  		UserMailer.with(user: {first_name: u.first_name, last_name: u.last_name, email: u.email}, newsletter: {articles: most_read_articles, subject: "Top 3 most popular articles of last week (#{1.week.before.strftime('%b %-d')} - #{Time.now.strftime('%b %-d')})"}).weekly_newsletter.deliver_now
  	end
  end

end