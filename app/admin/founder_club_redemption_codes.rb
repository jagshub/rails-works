# frozen_string_literal: true

ActiveAdmin.register FounderClub::RedemptionCode do
  menu label: 'Redemption Codes', parent: 'Founder Club'

  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  scope(:all, default: true, &:all)
  scope(:disabled, &:disabled)
  scope(:unlimited, &:unlimited)
  scope(:limited, &:limited)

  actions :all

  filter :code
  filter :deal

  index pagination_total: true do
    column :id
    column :deal
    column :code
    column :kind
    column :claims_count do |resource|
      link_to resource.claims_count, admin_founder_club_claims_path(q: { redemption_code_id: resource.id })
    end
    column :created_at
    actions
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes(:deal)
    end
  end

  form do |f|
    f.inputs 'Listing information' do
      f.input :code
      f.input :limit
    end
  end
end
