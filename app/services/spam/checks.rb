# frozen_string_literal: true

module Spam::Checks
  extend self

  def run_all(checks, **check_args)
    checks.reduce({}) do |spam_users, check|
      check.run(check_args).each do |user|
        check_name = check.name.split('::').last
        spam_users[user[:id]] ||= { failed_checks: [], actions: Set[] }
        spam_users[user[:id]][:failed_checks].push check_name
        spam_users[user[:id]][:actions].merge(user[:actions]) if user[:actions].present?
        spam_users[user[:id]][check_name] = user[:more_information] if user[:more_information].present?
        spam_users[user[:id]][check_name].merge!(period: check::PERIOD)
      end

      spam_users
    end
  end

  def perform_action(results, current_user:, kind: :automatic)
    User.where(id: results.keys).find_each do |user|
      details = results[user.id]
      details[:actions] = details[:actions].to_a

      break if already_alerted?(user, details)

      spam_log = Spam.log_entity(
        entity: user,
        user: user,
        kind: kind,
        action: details[:actions].empty? ? :alert : :mark_as_spam,
        level: :inappropriate,
        current_user: current_user,
        remarks: "User failed the following checks: #{ details[:failed_checks].join(', ') }.",
        more_information: details,
      )

      unless details[:actions].empty?
        Spam::SpamUserWorker.perform_later(
          {
            user: user,
            kind: kind.to_s,
            level: 'inappropriate',
            parent_log_id: spam_log.id,
            current_user: current_user,
          },
          actions: details[:actions],
        )
      end
    end
  end

  def already_alerted?(user, details)
    period = details[:failed_checks].map { |check_name| details[check_name][:period] }.max

    Spam::Log
      .root
      .where(user: user)
      .where(details[:actions].empty? ? { action: :alert, false_positive: true } : { action: :mark_as_spam })
      .where('more_information @> ?', details.to_json)
      .where('created_at >= ?', Time.zone.now - period)
      .any?
  end
end
