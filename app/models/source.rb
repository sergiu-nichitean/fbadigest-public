class Source < ApplicationRecord
	belongs_to :category
	has_many :posts

	def self.all_cached
		Rails.cache.fetch("sources/all_cached", expires_in: 24.hours) do
			Source.all
		end
	end
end
