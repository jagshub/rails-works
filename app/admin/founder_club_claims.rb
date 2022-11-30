# frozen_string_literal: true

ActiveAdmin.register FounderClub::Claim do
  menu label: 'Claims', parent: 'Founder Club'

  actions :index, :show, :destroy

  config.batch_actions = true
  config.per_page = 20
  config.paginate = true

  filter :redemption_code_id
  filter :user_id
  filter :user_name, as: :string
  filter :user_subscriber_email, as: :string, label: 'User Email'
  filter :deal
  filter :user_username_cont, label: 'Claimed by Username'
  filter :user_subscriber_email_cont, label: 'Claimed by Email'

  index pagination_total: true do
    selectable_column

    column :id
    column :user
    column :deal
    column :redemption_code
    column :created_at
    actions
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes(:user, :deal, :redemption_code)
    end
  end
end
