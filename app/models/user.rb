class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: ['facebook', 'google_oauth2']

 	has_one :filter, dependent: :destroy
 	has_many :webpush_subscriptions

 	has_many :saved_posts
 	has_many :actual_saved_posts, through: :saved_posts, source: :post

 	acts_as_commontator

 	def get_notification_sources
 		if notification_sources.nil? || notification_sources.empty?
 			Source.all_cached.collect{|s| s.id}
		else
			notification_sources
		end
 	end

 	def first_name_short
 		first_name.length > 12 ? "#{first_name[0..12]}..." : first_name
 	end

 	def is_omniauth?
 		!provider.nil?
 	end

 	def has_saved_posts?
		!saved_posts.empty?
 	end

 	def get_saved_posts
 		actual_saved_posts ? actual_saved_posts.order(published: :desc) : []
 	end

 	def saved_posts_count
 		saved_posts.count
 	end

 	def self.from_omniauth(auth)
 		unless self.where(provider: auth.provider, uid: auth.uid).first
			MiscMailer.with(user: {first_name: auth.info.name, last_name: '', email: auth.info.email}).new_user_email.deliver_now
			UserMailer.with(user: {first_name: auth.info.name, last_name: '', email: auth.info.email}).welcome_email.deliver_now
		end
	  
	  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
	    user.email = auth.info.email
	    user.password = Devise.friendly_token[0,20]
	    user.first_name = auth.info.name
	  end
	end
end
