class AddCategoryToSources < ActiveRecord::Migration[5.2]
  def change
  	add_reference :sources, :category, index: true
  end
end
