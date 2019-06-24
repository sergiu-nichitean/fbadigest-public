class AddNotificationsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notification_sources, :string
    add_reference :webpush_subscriptions, :user
  end
end
