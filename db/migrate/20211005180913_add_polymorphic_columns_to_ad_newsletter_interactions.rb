class AddPolymorphicColumnsToAdNewsletterInteractions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_reference :ads_newsletter_interactions, :subject, polymorphic: true, index: false
    add_index :ads_newsletter_interactions, [:subject_type, :subject_id],
              algorithm: :concurrently,
              name: 'index_ads_newsletter_interactions_on_subject_columns'
  end
end
