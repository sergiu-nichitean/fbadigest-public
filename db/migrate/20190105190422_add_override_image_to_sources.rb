class AddOverrideImageToSources < ActiveRecord::Migration[5.2]
  def change
  	add_column :sources, :override_image, :boolean
  end
end
