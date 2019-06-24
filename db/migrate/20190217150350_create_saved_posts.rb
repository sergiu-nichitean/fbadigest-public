class CreateSavedPosts < ActiveRecord::Migration[5.2]
  def change
    create_table :saved_posts do |t|
      t.references :user
      t.references :post
    end
  end
end
