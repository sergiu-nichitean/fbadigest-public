class ChangeImageUrl < ActiveRecord::Migration[5.2]
  def change
  	change_column :posts, :image_url, :text
  end
end
