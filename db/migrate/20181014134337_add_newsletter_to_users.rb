class AddNewsletterToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :newsletter_subscribed, :boolean
  end
end
