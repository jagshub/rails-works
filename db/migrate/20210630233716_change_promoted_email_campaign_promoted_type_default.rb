class ChangePromotedEmailCampaignPromotedTypeDefault < ActiveRecord::Migration[5.2]
  def up
    # NOTE(DZ) 1 = 'homepage'
    change_column_default :promoted_email_campaigns, :promoted_type, 1
  end

  def down
    # NOTE(DZ) 0 = 'signup_onboarding'
    change_column_default :promoted_email_campaigns, :promoted_type, 0
  end
end
