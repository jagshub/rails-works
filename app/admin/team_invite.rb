# frozen_string_literal: true

ActiveAdmin.register Team::Invite do
  menu label: 'Team invites', parent: 'Products'

  actions :all, except: %i(new create)

  config.batch_actions = true
  config.per_page = 20

  filter :user_id, label: 'User ID'
  filter :product_name, as: :string
  filter :status, as: :select, collection: Team::Invite.statuses

  index pagination_total: true do
    selectable_column

    column :id
    column :user
    column :email
    column :product
    column :referrer
    column :invite_link do |resource|
      link_to 'Team invite link', Routes.team_invite_path(resource)
    end
    column :identity_type
    column :status
    column :status_changed_at
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :id
      row :user
      row :email
      row :product
      row :referrer
      row :invite_link do |resource|
        link_to 'Team invite link', Routes.team_invite_path(resource)
      end
      row :identity_type
      row :status
      row :status_changed_at
      row :created_at
      row :updated_at
    end
  end

  permit_params %i(
    user_id
    email
    product_id
    referrer_id
    identity_type
    status
  )

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    f.inputs 'Team invite details' do
      f.input :user_id, as: :reference, label: 'User ID'
      f.input :email, required: false
      f.input :product_id, as: :reference, label: 'Product ID'
      f.input :referrer_id, as: :reference, label: 'Referrer ID'
      f.input :identity_type, as: :select, collection: Team::Invite.identity_types
      f.input :status, as: :select, collection: Team::Invite.statuses
    end

    f.actions
  end

  action_item :invalidate_invite, only: :show, if: -> { resource.pending? } do
    link_to 'Invalidate invite', action: :invalidate_invite
  end

  member_action :invalidate_invite do
    resource.update! status: :expired

    redirect_back(
      notice: "Invite #{ resource.id } has been invalidated.",
      fallback_location: admin_team_invites_path,
    )
  end
end
