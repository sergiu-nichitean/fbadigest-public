class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.string :slug
      t.references :category, foreign_key: true
      t.references :source, foreign_key: true
      t.string :external_url
      t.string :image_url

      t.timestamps
    end
  end
end
