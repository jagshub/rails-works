# frozen_string_literal: true

ActiveAdmin.register Spam::ManualLog do
  menu label: 'Manual Logs', parent: 'Spam'

  actions :index, :show

  permit_params %i(reason)

  config.batch_actions = true
  config.per_page = 20
  config.paginate = true

  filter :user_id
  filter :activity_type, as: :select, collection: Spam::ManualLog.activity_types
  filter :activity_id
  filter :handled_by_id
  filter :action, as: :select, collection: Spam::ManualLog.actions

  controller do
    def scoped_collection
      Spam::ManualLog.includes :user, :handled_by, :activity
    end
  end

  member_action :revert_action, method: :put do
    reason = params[:reason]

    SpamChecks.revert_manual_log resource, current_user, reason

    render json: :success
  end

  action_item :revert_action, only: :show, if: proc { resource.can_revert_action? } do
    link_to(
      'Revert Action',
      '#',
      data: {
        path: revert_action_admin_spam_manual_log_path(resource),
        name: 'reason',
        prompt: 'Enter reason to revert. Note: This will change user role back to user & revert trashed/hidden content.',
      },
      id: 'js-single-input-prompt',
    )
  end

  index do
    column :id
    column :user
    column :activity do |spam_manual_log|
      case spam_manual_log.activity
      when Vote
        "#{ pretty_format(spam_manual_log.activity) } on #{ pretty_format(spam_manual_log.activity.subject) }".html_safe
      else
        spam_manual_log.activity
      end
    end
    column :action
    column :reason
    column :handled_by
    column :created_at

    actions
  end
end
