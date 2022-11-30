# frozen_string_literal: true

ActiveAdmin.register Spam::ActionLog do
  menu label: 'Action Log', parent: 'Spam'

  config.batch_actions = true
  config.per_page = 20
  config.paginate = true

  filter :subject_type, as: :select, collection: Spam::ActionLog::SUBJECTS.map(&:name).sort
  filter :subject_id
  filter :user_id
  filter :spam
  filter :false_positive

  batch_action :revert_action, confirm: 'Are you sure you want to revert the action taken by spam system?' do |ids|
    batch_action_collection.find(ids).each do |log|
      SpamChecks.revert_action log, current_user
    end

    redirect_to admin_spam_action_logs_path, notice: 'Reverted the action'
  end

  controller do
    def scoped_collection
      Spam::ActionLog.includes :user, :ruleset, :reverted_by
    end
  end

  index do
    selectable_column

    column :id
    column :subject
    column 'avatar' do |spam_action_log|
      user_image(spam_action_log.user, size: 45)
    end
    column :user
    column :spam
    column :false_positive
    column :action_taken_on_activity
    column :action_taken_on_actor
    column :ruleset
    column :reverted_at
    column :reverted_by
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :id
      row :subject
      row 'avatar' do |spam_action_log|
        user_image(spam_action_log.user, size: 45)
      end
      row :user
      row :spam
      row :false_positive
      row :action_taken_on_activity
      row :action_taken_on_actor
      row :ruleset
      row :reverted_at
      row :reverted_by
      row :created_at
      row :updated_at
    end

    panel 'Rule Logs' do
      table_for spam_action_log.rule_logs do
        column :filter do |rule_log|
          rule_log.rule.filter_kind
        end
        column :checked_data do |rule_log|
          # Todo(Rahul): Show data in better & readable way, maybe as sentence used IP & value is XYZ
          rule_log.checked_data.to_json
        end
        column :filter_value
        column :custom_value
        column :spam
        column :false_positive
      end
    end
  end
end
