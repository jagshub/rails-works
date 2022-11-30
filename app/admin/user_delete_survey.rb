# frozen_string_literal: true

ActiveAdmin.register UserDeleteSurvey do
  menu label: 'Delete Survey', parent: 'Users'

  actions :all, except: %i(new create destroy edit update)

  config.per_page = 20
  config.paginate = true

  filter :user_name, as: :string, label: 'Name'
  filter :user_username, as: :string, label: 'UserName'
  filter :reason
  filter :feedback

  index pagination_total: false do
    selectable_column
    column :id
    column :name do |survey|
      format('%s', survey.user.name).html_safe
    end
    column :username do |survey|
      format('%s', survey.user.username).html_safe
    end
    column :reason
    column :feedback
    column 'Restore' do |survey|
      link_to 'Restore', edit_admin_user_restore_url(survey.user_id)
    end
  end
end
