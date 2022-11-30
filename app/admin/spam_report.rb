# frozen_string_literal: true

ActiveAdmin.register Spam::Report do
  menu label: 'Reports', parent: 'Spam'

  config.batch_actions = true
  config.per_page = 50
  config.paginate = true

  filter :user_id
  filter :action_log_subject_type, as: :select, collection: Spam::ActionLog.subject_types
  filter :action_log_subject_id, as: :string
  filter :handled_by_id
  filter :check, as: :select, collection: Spam::Report.checks
  filter :rule_name,
         as: :select,
         collection: proc { Spam::Ruleset.pluck(:name, :id).to_h }
  filter :post_id,
         as: :numeric,
         filters: [:equals]

  batch_action :mark_as_spam, confirm: 'Are you sure you want to mark this reported activity/user as spam?' do |ids|
    batch_action_collection.find(ids).each do |report|
      SpamChecks.mark_report_as_spam(report, current_user)
    end

    redirect_to admin_spam_reports_path, notice: 'Started mark as spam'
  end

  batch_action :mark_as_false_positive, confirm: 'Are you sure you want to mark this reported activity/user as false_positive?' do |ids|
    batch_action_collection.find(ids).each do |report|
      SpamChecks.mark_report_as_false_positive(report, current_user)
    end

    redirect_to admin_spam_reports_path, notice: 'Started mark as false positive'
  end

  scope :user_reports, default: true
  scope :activity_reports
  scope :all

  controller do
    def scoped_collection
      Spam::Report.includes :user, :handled_by, :action_log
    end
  end

  index do
    selectable_column

    column :id
    column :activity do |report|
      subject = report.action_log.subject

      if subject.is_a?(Comment)
        link_to("Comment ##{ subject.id }", admin_commentx_path(subject))
      else
        subject
      end
    end
    column 'Post Id' do |report|
      activity = report.action_log.subject
      is_post_activity = activity.respond_to?(:subject) && activity.subject.is_a?(Post)

      is_post_activity ? link_to(activity.subject_id, admin_spam_reports_path(q: { post_id_equals: activity.subject_id })) : nil
    end
    column 'Content' do |report|
      subject = report.action_log.subject

      subject.is_a?(Comment) || subject.is_a?(Review) ? subject.body : nil
    end
    column 'avatar' do |spam_action_log|
      user_image(spam_action_log.user, size: 45)
    end
    column 'user_id' do |report|
      link_to report.user_id, admin_spam_reports_path(q: { user_id_equals: report.user_id })
    end
    column :user
    column :registered_at do |spam_action_log|
      spam_action_log.user.created_at
    end
    column 'Confirmed Spam Count' do |spam_action_log|
      spam_action_log
        .user
        .spam_reports
        .marked_spam
        .count
    end
    column 'Pending Reports' do |spam_action_log|
      spam_action_log
        .user
        .spam_reports
        .not_handled
        .count
    end
    column 'email' do |spam_action_log|
      spam_action_log.user.email
    end
    column :check
    column :action_taken
    column :handled_by
    column :action_log
    column 'Reason' do |report|
      SpamChecks.report_reason(report.action_log)
    end
    column :created_at

    actions
  end
end
