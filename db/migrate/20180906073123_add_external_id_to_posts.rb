class AddExternalIdToPosts < ActiveRecord::Migration[5.2]
  def change
  	add_column :posts, :external_id, :string
  	add_column :posts, :og_image_url, :string
  end
end
