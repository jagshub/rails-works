# frozen_string_literal: true

ActiveAdmin.register Onboarding do
  menu label: 'Onboarding', parent: 'Users'

  actions :all

  permit_params %i(user_id name status step)

  config.per_page = 20
  config.paginate = true

  filter :id
  filter :user_id
  filter :name
  filter :status
  filter :step

  controller do
    def scoped_collection
      Onboarding.includes(:user)
    end
  end

  index do
    column :id
    column :user
    column :name
    column :status
    column :step

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :user_id
      f.input :name
      f.input :step
      f.input :status
    end

    f.actions
  end
end
