class Category < ApplicationRecord
	has_many :sources

	def self.all_cached
		Rails.cache.fetch("categories/all_cached", expires_in: 24.hours) do
			Category.all
		end
	end
end
