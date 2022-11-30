class RemoveNullConstraintOnAdsNewsletterInteractionNewsletter < ActiveRecord::Migration[5.2]
  def change
    change_column_null :ads_newsletter_interactions, :ads_newsletter_id, true
  end
end
