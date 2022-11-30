# frozen_string_literal: true

ActiveAdmin.register Shoutout do
  menu label: 'Shoutouts', parent: 'Others'

  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  scope(:active, default: true, &:not_trashed)
  scope(:trashed, &:trashed)

  actions :all

  filter :user_id
  filter :body
  filter :by_year, as: :number

  index pagination_total: true do
    column :id
    column :user
    column :body
    column :votes_count
    column :priority
    column :created_at
    column :trashed_at
    actions
  end

  controller do
    def scoped_collection
      super.includes [:user]
    end
  end

  member_action :trash, method: :put do
    resource.trash
    redirect_to resource_path, notice: 'Shoutout was trashed!'
  end

  member_action :restore, method: :put do
    resource.restore
    redirect_to resource_path, notice: 'Shoutout has been restored!'
  end

  action_item 'Trash Post', only: %i(edit show) do
    if resource.trashed?
      link_to 'Restore', restore_admin_shoutout_url(resource), method: :put
    else
      link_to 'Trash (Can be restored)', trash_admin_shoutout_url(resource), method: :put
    end
  end

  permit_params :user_id, :body, :priority

  form do |f|
    f.inputs 'Details' do
      f.input :user_id, as: :reference
      f.input :body
      f.input :priority, hint: 'Used for ordering of Shout-outs. Bigger the better. Default: 0.'
    end
    f.actions
  end
end
