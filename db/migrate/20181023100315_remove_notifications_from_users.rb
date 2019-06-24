class RemoveNotificationsFromUsers < ActiveRecord::Migration[5.2]
  def change
  	remove_column :users, :notification_sources
    add_column :users, :notification_sources, :json
  end
end
