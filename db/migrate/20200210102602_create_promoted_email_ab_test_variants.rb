class CreatePromotedEmailAbTestVariants < ActiveRecord::Migration[5.1]
  def change
    create_table :promoted_email_ab_test_variants do |t|
      t.string :title
      t.string :tagline
      t.uuid :thumbnail_uuid
      t.references :promoted_email_ab_test, foreign_key: true, null: false, index: { name: 'index_promoted_email_ab_variants_on_ab_test_id' }

      t.timestamps
    end
  end
end
