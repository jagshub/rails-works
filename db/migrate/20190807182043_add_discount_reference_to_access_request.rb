class AddDiscountReferenceToAccessRequest < ActiveRecord::Migration[5.1]
  def change
    add_reference :founder_club_access_requests, :payment_discount, foreign_key: true
  end
end
