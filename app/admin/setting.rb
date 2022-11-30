# frozen_string_literal: true

ActiveAdmin.register Setting do
  menu label: 'Settings', parent: 'Others', priority: 1

  permit_params :name, :value

  config.filters = false

  index pagination_total: false do
    column :name
    column :value

    actions
  end

  controller do
    def create
      @setting = Setting.create(permitted_params[:setting].merge(id: Setting.next_id))

      respond_with @setting, location: admin_settings_path
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :name
      f.input :value, hint: 'To say "false" use 0 or leave it blank'
    end
    f.actions
  end
end
