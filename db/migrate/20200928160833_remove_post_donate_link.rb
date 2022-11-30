class RemovePostDonateLink < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      remove_column :posts, :donation_link
    end
  end
end
