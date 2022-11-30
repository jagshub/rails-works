# frozen_string_literal: true

ActiveAdmin.register FounderClub::AccessRequest do
  menu label: 'Waitlist', parent: 'Founder Club'

  actions :index, :destroy

  config.batch_actions = true
  config.per_page = 60
  config.paginate = true

  scope(:all, &:all)
  scope(:referral, &:referral)
  scope(:waiting_for_code) { |scope| scope.where(received_code_at: nil) }
  scope(:received_code_at, &:received_code)
  scope(:used_code, &:used_code)
  scope(:subscribed, &:subscribed)

  filter :email
  filter :user_id
  filter :created_at

  index pagination_total: true do
    selectable_column

    column :id
    column :email
    column :user
    column :invite_code
    column :created_at
    column :received_code_at
    column :used_code_at
    column :subscribed_at
    column :deal
    column :source do |resource|
      if resource.referral?
        raw "Referral by #{ link_to resource.invited_by_user.username, [:admin, resource.invited_by_user] if resource.invited_by_user }"
      else
        raw 'Waitlist'
      end
    end
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes(:user, :deal, :invited_by_user)
    end
  end
end
