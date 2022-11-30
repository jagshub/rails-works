# frozen_string_literal: true

ActiveAdmin.register_page 'Spam Dashboard' do
  menu label: 'Dashboard', parent: 'Spam', priority: 1

  content do
    div render('charts')
  end

  sidebar :stats do
    ul do
      li "Users To Check: #{ Spam::Report.user_reports.count }"
      li "Activities To Check: #{ Spam::Report.activity_reports.count }"
    end
  end

  action_item :user_reports do
    link_to 'View Suspected Spam Users', admin_spam_reports_path(scope: 'user_reports')
  end

  action_item :activity_reports do
    link_to 'View Suspected Spam Activities', admin_spam_reports_path(scope: 'activity_reports')
  end
end
