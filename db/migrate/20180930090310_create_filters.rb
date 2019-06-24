class CreateFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :filters do |t|
      t.text :data
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
