class AddLastLoggedinToUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :last_visit, :datetime
  end
end
