# frozen_string_literal: true

ActiveAdmin.register PromotedEmail::AbTestVariant do
  menu label: 'Promoted -> Email ABTest Variant', parent: 'Revenue'

  actions :all
  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  filter :id
  filter :promoted_email_ab_test_id

  action_item :view_ab_test, only: :show do
    link_to 'View A/B Test', admin_promoted_email_ab_test_url(resource.promoted_email_ab_test)
  end

  controller do
    before_action do
      @page_title = 'Promoted Email AB Test Variant (DEPRECATED)'
    end

    def scoped_collection
      PromotedEmail::AbTestVariant.includes(:promoted_email_ab_test)
    end
  end
end
