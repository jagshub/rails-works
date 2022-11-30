class AddPromoCodeToPost < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :promo_code, :string, null: true
    add_column :posts, :promo_text, :string, null: true
    add_column :posts, :promo_expire_at, :datetime, null: true
  end
end
