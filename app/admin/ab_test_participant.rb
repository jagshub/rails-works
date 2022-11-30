# frozen_string_literal: true

ActiveAdmin.register AbTest::Participant do
  menu label: 'AbTest -> Participants', parent: 'Others'

  actions :index, :show

  filter :test_name
  filter :variant
  filter :user_id
  filter :visitor_id
  filter :anonymous_id

  config.per_page = 20
  config.paginate = true

  controller do
    def scoped_collection
      AbTest::Participant.includes(:user)
    end
  end

  index do
    id_column
    column :test_name
    column :variant
    column :user
    column :visitor_id
    column :anonymous_id
    column :completed_at
    column :created_at

    actions
  end
end
