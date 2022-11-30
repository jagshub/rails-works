# frozen_string_literal: true

ActiveAdmin.register PromotedProductCampaign do
  # NOTE(DZ): PromotedProductCampaign is deprecated, use 'AdsCampaigns' instead
  # Deprecation date 2020-01-04
  actions :index, :show

  controller do
    before_action do
      @page_title = 'Promoted Product Campaigns (DEPRECATED)'
    end
  end

  menu label: 'Promoted -> Product Campaigns', parent: 'Revenue'
  permit_params :name, :impressions_cap

  index do
    column :id
    column :name
    column :impressions_cap
    column :impressions_count
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :impressions_cap
    end
  end

  form do |f|
    f.inputs 'Promoted Products Campaigns' do
      f.input :name
      f.input :impressions_cap
    end

    f.actions
  end
end
