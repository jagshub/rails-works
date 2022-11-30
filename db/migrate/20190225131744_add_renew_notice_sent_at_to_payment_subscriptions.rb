class AddRenewNoticeSentAtToPaymentSubscriptions < ActiveRecord::Migration[5.0]
  def change
    change_table :payment_subscriptions do |t|
      t.datetime :renew_notice_sent_at
    end
  end
end
