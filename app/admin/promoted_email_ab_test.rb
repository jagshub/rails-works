# frozen_string_literal: true

ActiveAdmin.register PromotedEmail::AbTest do
  menu label: 'Promoted -> Email ABTest', parent: 'Revenue'
  actions :all, except: %i(edit new)

  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  filter :id

  controller do
    before_action do
      @page_title = 'Promoted Email AB Test (DEPRECATED)'
    end
  end

  show do
    attributes_table do
      row :id
      row 'A/B Test Name' do |ab_test|
        "email_capture_#{ ab_test.id }"
      end
      row :test_running
    end

    panel 'Campaigns' do
      table_for promoted_email_ab_test.campaigns do
        column :id
        column :campaign_name
        column :start_date
        column :end_date
        column do |campaign|
          link_to('View', admin_promoted_email_campaign_url(campaign))
        end
      end
    end

    panel 'Variants' do
      table_for promoted_email_ab_test.variants do
        column 'variant name' do |variant|
          "variant_#{ variant.id }"
        end
        column :title
        column :tagline
        column do |variant|
          link_to('View', admin_promoted_email_ab_test_variant_url(variant))
        end
      end
    end
  end
end
