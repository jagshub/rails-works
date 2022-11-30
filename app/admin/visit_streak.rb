# frozen_string_literal: true

ActiveAdmin.register VisitStreak do
  menu label: 'Visit Streaks', parent: 'Users'

  actions :all, except: %i(new create)

  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  filter :id
  filter :user_id

  controller do
    def scoped_collection
      VisitStreak.preload [:user]
    end
  end

  index pagination_total: false do
    column :id
    column :user
    column :duration
    column :created_at
    column :last_visit_at
    column :ended_at
  end
end
