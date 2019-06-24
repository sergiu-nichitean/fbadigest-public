class Post < ApplicationRecord
  belongs_to :category
  belongs_to :source

  has_many :saved_posts

  acts_as_commontable dependent: :destroy

  # override for no internet
  # def image_url
  #		images = [
  #			'/Seychelles-6-shutterstock_298384343.jpg',
  #			'/ebc-feature2.jpg',
  #			'/moon-over-new-york.jpg'
  #		]
  #
  #		images[rand(3)]
  # end

  def final_image_url
  	if image_url && !image_url.empty? && !source.override_image?
  		image_url
  	else
  		default_image_url
  	end
  end

  def default_image_url
  	source.default_image_url
	end

	def internal?
		category_id == 3
	end

	def absolute_url
		"https://www.fbadigest.com/#{slug}"
	end

  def clean_title
    final_title = ActionController::Base.helpers.strip_tags(title)
    final_title = final_title.gsub('&amp;', '&')
    final_title = final_title.gsub('&apos;', '\'')
    final_title.gsub(/&(.*?);/, '')
  end

	def clean_content
		final_content = ActionController::Base.helpers.strip_tags(content).strip
		final_content = final_content.gsub('&amp;', '&')
    final_content = final_content.gsub('&apos;', '\'')
    final_content = final_content.gsub("\n", ' ')
    final_content = final_content.gsub('    ', ' ')
    final_content = final_content.gsub('   ', ' ')
    final_content = final_content.gsub('  ', ' ')
		final_content.gsub(/&(.*?);/, '')
	end

  def is_saved_by?(user)
    !saved_posts.where(user_id: user.id).empty?
  end

  def get_sidebar_posts
    Rails.cache.fetch("posts/get_sidebar_posts#{id}", expires_in: 24.hours) do
      blogosphere = Post.where('category_id = 2').order(published: :desc).limit(2)
      news = Post.where('category_id = 4').order(published: :desc).limit(2)
      fbadigest = Post.where('category_id = 3').order(published: :desc).limit(1)
      press_releases = Post.where('category_id = 1').order(published: :desc).limit(1)
      Post.where('id IN (?)', blogosphere.collect{|p| p.id} + news.collect{|p| p.id} + fbadigest.collect{|p| p.id} + press_releases.collect{|p| p.id}).order(published: :desc)
    end
  end

  def get_related_posts
    Rails.cache.fetch("posts/get_related_posts#{id}", expires_in: 24.hours) do
      Post.where('source_id = ?', source_id).order(published: :desc).limit(3)
    end
  end

	def self.load_cached(sources, posts_per_page, page)
		Rails.cache.fetch("posts/load_cached#{sources.join('')}#{posts_per_page}#{page}", expires_in: 24.hours) do
      Post.where('source_id IN (?)', sources).order(published: :desc).limit(posts_per_page).offset((page.to_i - 1) * posts_per_page)
    end
	end

	def self.search_cached(sources, search_string, posts_per_page, page)
		Rails.cache.fetch("posts/search_cached#{sources.join('')}#{search_string}#{posts_per_page}#{page}", expires_in: 24.hours) do
      Post.where('source_id IN (?) AND (LOWER(title) LIKE ? OR LOWER(content) LIKE ?)', sources, "%#{search_string.downcase}%", "%#{search_string.downcase}%").order(published: :desc).limit(posts_per_page).offset((page.to_i - 1) * posts_per_page)
    end
	end

	def self.all_results_cached(sources, search_string)
		Rails.cache.fetch("posts/search_cached#{sources.join('')}#{search_string}", expires_in: 24.hours) do
      Post.where('source_id IN (?) AND (LOWER(title) LIKE ? OR LOWER(content) LIKE ?)', sources, "%#{search_string.downcase}%", "%#{search_string.downcase}%").count
    end
	end

  def self.new_posts_today
    Rails.cache.fetch('posts/new_today', expires_in: 2.hours) do
      Post.where('published > ?', 24.hours.ago).count
    end
  end

  def self.get_unique_slug(post)
    slug = ActionController::Base.helpers.strip_tags(post.title).parameterize
    check = Post.where('slug = ?', slug).first

    if check
      "#{slug}-#{post.id}"
    else
      slug
    end
  end

  def self.fetch_blogosphere
  	puts "Fetching Blogoshpere"
  	
  	new_posts = []

		Source.where(category_id: 2).each do |source|
			puts "Fetching #{source.name}"

			begin
				xml = HTTParty.get(source.url).body
				feed = Feedjira::Feed.parse(xml)
				can_parse = true
			rescue => e
				puts "RESCUE (Source ID = #{source.id}): #{e.message}"
				can_parse = false
			end

			if can_parse
				feed.entries.each do |entry|
					check = Post.where(external_id: entry.entry_id).first

					unless check
						article_source = HTTParty.get(entry.url).body
            og_image_matches = /property="og\:image" content="(.*?)"/.match(article_source)
            og_image_matches_reverse = /content="(.*?)" property="og\:image"/.match(article_source)
            og_image_matches_alt = /property="og:image" itemprop="image" content="(.*?)"/.match(article_source)
            if og_image_matches
              image_url = og_image_matches[1]
            elsif og_image_matches_reverse
              image_url = og_image_matches_reverse[1]
            elsif og_image_matches_alt
              image_url = og_image_matches_alt[1]
            elsif feed.image
              image_url = feed.image.url
            else
              image_url = nil
            end

            if /http\:\/\//.match(image_url)
              image_url = nil
            end
            
						new_post = source.posts.create(
							title: entry.title,
							content: entry.summary.scrub,
							category_id: 2,
							external_url: entry.url,
							external_id: entry.entry_id,
							image_url: image_url,
							published: entry.published
						)

            new_post.update(slug: Post.get_unique_slug(new_post))

						new_posts << {
							title: entry.title,
							source: source.name,
							source_id: source.id
						}
					end
				end
			end
		end

		puts "#{new_posts.count} new posts from Blogoshpere"
		new_posts
	end

	def self.fetch_news_sites
		puts "Fetching News sites"

		new_posts = []

		Source.where(category_id: 4).each do |source|
			puts "Fetching #{source.name}"

			begin
				xml = HTTParty.get(source.url).body
				feed = Feedjira::Feed.parse(xml)
				can_parse = true
			rescue => e
				puts "RESCUE (Source ID = #{source.id}): #{e.message}"
				can_parse = false
			end

			if can_parse
				feed.entries.each do |entry|
					check = Post.where(external_id: entry.entry_id).first

					if /Amazon/.match(entry.title) && !check
						article_source = HTTParty.get(entry.url).body
            og_image_matches = /property="og\:image" content="(.*?)"/.match(article_source)
            og_image_matches_reverse = /content="(.*?)" property="og\:image"/.match(article_source)
            og_image_matches_alt = /property="og:image" itemprop="image" content="(.*?)"/i.match(article_source)
            if og_image_matches
              image_url = og_image_matches[1]
            elsif og_image_matches_reverse
              image_url = og_image_matches_reverse[1]
            elsif og_image_matches_alt
              image_url = og_image_matches_alt[1]
            elsif feed.image
              image_url = feed.image.url
            else
              image_url = nil
            end

						if /http\:\/\//.match(image_url)
							image_url = nil
						end

						new_post = source.posts.create(
							title: entry.title,
							content: entry.summary.scrub,
							category_id: 4,
							external_url: entry.url,
							external_id: entry.entry_id,
							image_url: image_url,
							published: entry.published
						)

            new_post.update(slug: Post.get_unique_slug(new_post))

						new_posts << {
							title: entry.title,
							source: source.name,
							source_id: source.id
						}
					end
				end
			end
		end

		puts "#{new_posts.count} new posts from News sites"
		new_posts		
	end

	def self.fetch_amazon_official
		puts "Fetching Amazon Official"

		new_posts = []

		# FBA News & Updates
		# https://services.amazon.com/fulfillment-by-amazon/news-and-updates.html

		fba_news = Source.find(9)
		puts "Fetching #{fba_news.name}"

		begin
			html_source = HTTParty.get(fba_news.url).body
			can_parse = true
		rescue => e
			puts "RESCUE (Source ID = #{fba_news.id}): #{e.message}"
			can_parse = false
		end

		if can_parse
			post_elements = html_source.scan(/<div class=" as-padding as-padding-xs-no-top as-padding-xs-no-right as-padding-xs-no-bottom as-padding-xs-no-left as-padding-sm-no-top as-padding-sm-no-right as-padding-sm-no-bottom as-padding-sm-no-left text-left"><h3 class="as-heading" >(.*?)<div class="clearfix">(.*?)Last published: (.*?)\n(.*?)<div class="clearfix">/m)
			post_elements.collect!{|e| {title: e[0], published: e[2], content: e[3]} }

			post_elements.each do |post|
				external_id = "fba-news-#{ActionController::Base.helpers.strip_tags(post[:title]).parameterize}"
				check = Post.where(external_id: external_id).first
				unless check
					new_post = fba_news.posts.create(
						title: ActionController::Base.helpers.strip_tags(post[:title]),
						content: ActionController::Base.helpers.strip_tags(post[:content]),
						category_id: 1,
						external_url: fba_news.url,
						external_id: external_id,
						published: ActionController::Base.helpers.strip_tags(post[:published])
					)

          new_post.update(slug: Post.get_unique_slug(new_post))

					new_posts << {
						title: ActionController::Base.helpers.strip_tags(post[:title]),
						source: fba_news.name,
						source_id: fba_news.id
					}
				end
			end
		end

		# TODO: Amazon Press Releases
		# https://press.aboutamazon.com/press-releases?c=176060&nyo=0&p=irol-news

		press_releases = Source.find(1)
		puts "Fetching #{press_releases.name}"
		
		begin
			html_source = HTTParty.get(press_releases.url).body
			can_parse = true
		rescue => e
			puts "RESCUE (Source ID = #{press_releases.id}): #{e.message}"
			can_parse = false
		end

		if can_parse
			urls_and_published = html_source.scan(/<div class="nir-widget--field nir-widget--news--date-time">\n(.*?)\n(.*?)<\/div>\n(.*?)\n(.*?)\n(.*?)<a href="(.*?)" hreflang="en">(.*?)<\/a>\n(.*?)<\/div>/)
			urls_and_published.collect!{|p| {url: p[5], title: p[6], published: p[0].gsub(' ', '')} }
			urls_and_published.reject!{|p| /AWS/i.match(p[:title]) || /Amazon Web Services/i.match(p[:title])}

			urls_and_published.each do |post|
				external_id = "amazon-pr-#{ActionController::Base.helpers.strip_tags(post[:title]).parameterize}"

				check = Post.where(external_id: external_id).first

				unless check
					url = "https://press.aboutamazon.com#{post[:url]}"
					post_source = HTTParty.get(url).body

					content = post_source.scan(/<div class="box__right">(.*?)<\/body>/m)
					content = content[0][0]
					content = ActionController::Base.helpers.strip_tags(content)
					content = content[0..1000]

					new_post = press_releases.posts.create(
						title: ActionController::Base.helpers.strip_tags(post[:title]),
						content: content,
						category_id: 1,
						external_url: url,
						external_id: external_id,
						image_url: nil,
						published: ActionController::Base.helpers.strip_tags(post[:published])
					)

          new_post.update(slug: Post.get_unique_slug(new_post))

					new_posts << {
						title: ActionController::Base.helpers.strip_tags(post[:title]),
						source: press_releases.name,
						source_id: press_releases.id
					}
				end		
			end
		end

		# Amazon's advertising blog
		# https://advertising.amazon.com/blog/

		advertising_blog = Source.find(10)
		puts "Fetching #{advertising_blog.name}"

		begin
			html_source = HTTParty.get(advertising_blog.url).body
			can_parse = true
		rescue => e
			puts "RESCUE (Source ID = #{advertising_blog.id}): #{e.message}"
			can_parse = false
		end

		if can_parse
			post_titles = html_source.scan(/<h3 id="(.*?)">(.*?)<\/h3>/m)
			post_urls = html_source.scan(/<a href="(.*?)">\(read more\)<\/a><\/p>/)

			posts = []
			post_titles.each_with_index{|p, i| posts << {title: p[1].gsub(/\n|  /, ''), url: post_urls[i][0]} }

			posts.each do |post|
				url = "https://advertising.amazon.com#{post[:url]}"
				external_id = "advertising-#{ActionController::Base.helpers.strip_tags(post[:title]).parameterize}"
				
				check = Post.where(external_id: external_id).first
				
				unless check || /\.com\//.match(url).nil?
					post_source = HTTParty.get(url).body
					image_url = post_source.scan(/<div class="jumbotron bg-medium" style="background: url\((.*?)\) center center;background-size: cover;">/)
					
					if image_url.empty?
						image_url = post_source.scan(/<div class="jumbotron bg-medium" style="background: url\((.*?)\n/)
					end

					if image_url.empty?
						image_url = nil
					else
						image_url = image_url[0][0]
					end

					published = post_source.scan(/<div class="description"><p>(.*?) \| /)
					published = published[0][0]

					content = post_source.scan(/<div class="section-body">\n(.*?)<\/div>/m)
					content = content[0][0]

					new_post = advertising_blog.posts.create(
						title: ActionController::Base.helpers.strip_tags(post[:title]),
						content: ActionController::Base.helpers.strip_tags(content),
						category_id: 1,
						external_url: url,
						external_id: external_id,
						image_url: image_url,
						published: ActionController::Base.helpers.strip_tags(published)
					)

          new_post.update(slug: Post.get_unique_slug(new_post))

					new_posts << {
						title: ActionController::Base.helpers.strip_tags(post[:title]),
						source: advertising_blog.name,
						source_id: advertising_blog.id
					}
				end
			end
		end

		puts "#{new_posts.count} new posts from Amazon Official"
		new_posts
	end
end