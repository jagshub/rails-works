class AddDonationLinkToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :donation_link, :string
  end
end
