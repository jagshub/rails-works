class AddAbTestToPromotedEmailCampaign < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_reference :promoted_email_campaigns, :promoted_email_ab_test, foreign_key: true, null: true, index: false

    add_index :promoted_email_campaigns, :promoted_email_ab_test_id, algorithm: :concurrently, name: 'index_promoted_email_campaigns_on_ab_test_id', where: 'promoted_email_ab_test_id IS NOT NULL'
  end
end
