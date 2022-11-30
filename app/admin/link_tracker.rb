# frozen_string_literal: true

ActiveAdmin.register LinkTracker do
  menu label: 'Unique Clickthroughs', parent: 'Posts'

  config.per_page = 100

  permit_params :post_id, :user_id, :track_code, :ip_address

  filter :post_name, as: :string
  filter :user_username, as: :string
  filter :user_name, as: :string

  index pagination_total: false do
    column :post_id do |post|
      post.post.name
    end
    column :user_id do |post|
      post.user.username unless post.user_id.nil?
    end
    column :track_code
    column :ip_address
    actions
  end
end
