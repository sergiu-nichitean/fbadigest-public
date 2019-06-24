class WebpushSubscription < ApplicationRecord
	belongs_to :user, optional: true
	validates :p256dh, uniqueness: true
end
