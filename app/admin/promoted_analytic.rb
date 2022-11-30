# frozen_string_literal: true

ActiveAdmin.register PromotedAnalytic do
  # NOTE(DZ): PromotedAnalytic is deprecated
  # Deprecation date 2020-01-04
  actions :index

  menu label: 'Promoted -> Analytics', parent: 'Revenue'

  controller do
    before_action do
      @page_title = 'Promoted Analytics (DEPRECATED)'
    end
  end

  config.batch_actions = false
  config.per_page = 40
  config.paginate = true

  filter :created_at

  index do
    column :id
    column :promoted_product_id
    column :user
    column :ip_address
    column :track_code
    column :source
    column :user_action
    column :created_at
  end
end
