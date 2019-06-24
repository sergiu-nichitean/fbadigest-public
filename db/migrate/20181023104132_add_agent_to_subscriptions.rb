class AddAgentToSubscriptions < ActiveRecord::Migration[5.2]
  def change
  	add_column :webpush_subscriptions, :user_agent, :string
  end
end
