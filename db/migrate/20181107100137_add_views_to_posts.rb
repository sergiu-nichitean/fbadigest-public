class AddViewsToPosts < ActiveRecord::Migration[5.2]
  def change
  	add_column :posts, :views, :bigint
  end
end
