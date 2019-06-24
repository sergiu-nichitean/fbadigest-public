class CreateWebpushSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :webpush_subscriptions do |t|
      t.string :endpoint
      t.string :p256dh
      t.string :auth

      t.timestamps
    end
  end
end
