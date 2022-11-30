# frozen_string_literal: true

ActiveAdmin.register PostTopicAssociation do
  menu label: 'Topic Posts', parent: 'Posts'

  actions :all, except: %i(new create show edit update)

  config.batch_actions = false
  config.per_page = 50

  filter :post_name, as: :string
  filter :topic_name, as: :string
  filter :user_username, as: :string
  filter :user_role, as: :select, collection: User.roles

  controller do
    def scoped_collection
      PostTopicAssociation.includes(:user, :post, :topic)
    end
  end

  index do
    column :id
    column :post do |assoc|
      link_to assoc.post.name, admin_post_path(assoc.post)
    end
    column :topic do |assoc|
      link_to assoc.topic.name, admin_topic_path(assoc.topic)
    end
    column :user do |assoc|
      link_to assoc.user.name, admin_user_path(assoc.user) if assoc.user.present?
    end
    column 'Admin?' do |assoc|
      if assoc.user.present?
        status_tag(assoc.user.admin? ? 'Yes' : 'No')
      end
    end
    column :created_at
    actions
  end
end
