# frozen_string_literal: true

ActiveAdmin.register Spam::Log do
  menu label: 'Log', parent: 'Spam'
  config.batch_actions = true

  permit_params %i(content user_id more_information content_type kind parent_log_id level)
  controller do
    def scoped_collection
      Spam::Log.includes :user
      Spam::Log.includes :parent_log
    end
  end

  config.per_page = 20
  config.paginate = true

  filter :user_id
  filter :by_username, as: :string
  filter :kind, as: :select, collection: Spam::Log.kinds
  filter :level, as: :select, collection: Spam::Log.levels
  filter :action, as: :select, collection: Spam::Log.actions
  filter :content_type, as: :select, collection: Spam::Log.content_types
  filter :by_check, as: :select, collection: %w(similar_votes twitter_suspension similar_username sibling_users)
  filter :by_author, as: :string
  filter :by_subject_type, as: :select, collection: %w(Post)
  filter :by_subject_id, as: :number
  filter :created_at

  index do
    selectable_column

    column :id
    column :content
    column :content_type
    column :user
    column :action
    column :level
    column :parent_log
    column :remarks
    column :more_information
    column :kind
    column :created_at
    column :false_positive

    actions do |resource|
      if resource.parent?
        if resource.false_positive?
          span link_to 'Positive', [:set_positive, :admin, resource], method: :patch
        else
          span link_to 'False Positive', [:set_false_positive, :admin, resource], method: :patch
        end
      end

      span link_to 'Spammer', [:mark_spammer, :admin, resource], method: :post
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :parent_log_id
      f.input :content_type, as: :select, collection: Spam::Log.content_types.keys, include_blank: false
      f.input :kind, as: :select, collection: Spam::Log.kinds.keys, include_blank: false
      f.input :action, as: :select, collection: Spam::Log.actions.keys, include_blank: false
      f.input :level, as: :select, collection: Spam::Log.levels.keys, include_blank: false
      f.input :content
      f.input :remarks
      f.input :more_information, as: :string
      f.input :user_id
      f.input :false_positive
    end

    f.actions
  end

  batch_action :set_false_positive do |ids|
    Spam::Log.where(id: ids).update_all(false_positive: true)
    redirect_to collection_path
  end

  batch_action :mark_as_spammer do |ids|
    Spam::Log.where(id: ids).find_each do |log|
      Spam::SpamUserWorker.perform_later(
        user: log.user,
        kind: 'manual',
        level: log.level,
        current_user: current_user,
        parent_log_id: log.id,
      )
    end
    redirect_to collection_path
  end

  member_action :set_false_positive, method: :patch do
    log = Spam::Log.find(params[:id])
    log.update! false_positive: true
    redirect_to collection_path
  end

  member_action :set_positive, method: :patch do
    log = Spam::Log.find(params[:id])
    log.update! false_positive: false
    redirect_to collection_path
  end

  member_action :mark_spammer, method: :post do
    log = Spam::Log.find(params[:id])
    Spam::SpamUserWorker.perform_later(
      user: log.user,
      kind: 'manual',
      level: log.level,
      current_user: current_user,
      parent_log_id: log.id,
    )
    redirect_to collection_path
  end
end
