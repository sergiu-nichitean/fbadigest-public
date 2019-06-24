class ChangeViewsToPosts < ActiveRecord::Migration[5.2]
  def change
  	remove_column :posts, :views
  	add_column :posts, :views, :integer, null: false, default: 0
  end
end
