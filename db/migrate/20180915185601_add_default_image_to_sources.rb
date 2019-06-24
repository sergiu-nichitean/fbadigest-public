class AddDefaultImageToSources < ActiveRecord::Migration[5.2]
  def change
  	add_column :sources, :default_image_url, :string
  end
end
