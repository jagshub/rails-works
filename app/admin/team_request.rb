# frozen_string_literal: true

ActiveAdmin.register Team::Request do
  menu label: 'Team requests', parent: 'Products'

  actions :all

  config.batch_actions = true
  config.per_page = 20

  filter :user_id, label: 'User ID'
  filter :product_name, as: :string
  filter :status, as: :select, collection: Team::Request.statuses
  filter :approval_type, as: :select, collection: Team::Request.approval_types

  index pagination_total: true do
    selectable_column

    column :id
    column :user
    column :product
    column :approval_type
    column :team_email
    column :team_email_confirmed
    column :additional_info
    column :moderation_notes
    column :status
    column :status_changed_by do |resource|
      link_to resource.status_changed_by_id, admin_user_path(resource.status_changed_by_id) if resource.status_changed_by_id?
    end
    column :status_changed_at
    column :verification_token
    column :verification_token_generated_at
    column :created_at

    actions

    column do |resource|
      link_to 'Approve', approve_admin_team_request_path(resource), method: :put
    end

    column do |resource|
      link_to 'Reject', reject_admin_team_request_path(resource), method: :put
    end
  end

  permit_params %i(
    user_id
    product_id
    team_email
  )

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    f.inputs 'Team request details' do
      f.input :user_id, as: :reference, label: 'User ID'
      f.input :product_id, as: :reference, label: 'Product ID'
      f.input :team_email, required: false
    end

    f.actions
  end

  member_action :approve, method: :put do
    Teams.request_approve(
      request: resource,
      approval_type: :manual,
      status_changed_by: current_user,
    )

    redirect_to action: :index
  end

  batch_action :approve do |ids|
    batch_action_collection.find(ids).each do |team_request|
      Teams.request_approve(
        request: team_request,
        approval_type: :manual,
        status_changed_by: current_user,
      )
    end

    redirect_to action: :index
  end

  member_action :reject, method: :put do
    Teams.request_reject(request: resource, status_changed_by: current_user)

    redirect_to action: :index
  end

  batch_action :reject do |ids|
    batch_action_collection.find(ids).each do |team_request|
      Teams.request_reject(request: team_request, status_changed_by: current_user)
    end

    redirect_to action: :index
  end
end
