class Filter < ApplicationRecord
  belongs_to :user

  serialize :data
end
