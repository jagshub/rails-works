# frozen_string_literal: true

ActiveAdmin.register PromotedEmail::Campaign do
  menu label: 'Promoted -> Email', parent: 'Revenue'

  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  filter :campaign_name
  filter :promoted_type, as: :select, collection: PromotedEmail::Campaign.promoted_types
  filter :start_date
  filter :end_date

  controller do
    before_action do
      @page_title = 'Promoted Email Campaigns (DEPRECATED)'
    end
  end

  index do
    column :id
    column :promoted_type
    column :campaign_name
    column :title
    column :tagline
    column :start_date
    column :end_date
    column :webhook_enabled
    column :signups_count
    column 'Overall Signups Count' do |campaign|
      campaign.campaign_config&.signups_count
    end
    column 'Overall Signups Cap' do |campaign|
      campaign.campaign_config&.signups_cap
    end

    actions
  end

  show do
    attributes_table do
      row :id
      row :campaign_name
      row :title
      row :tagline
      row :cta_text
      row :thumbnail_uuid
      row :promoted_type
      row :start_date
      row :end_date
      row :webhook_enabled
      row :webhook_url
      row :webhook_auth_header
      row :webhook_payload
      row :promoted_email_ab_test_id
    end

    panel 'Campaign Config' do
      attributes_table_for promoted_email_campaign.campaign_config do
        row :signups_cap
      end
    end
  end
end
