# frozen_string_literal: true

module SpamChecks::Filters::IpFilter
  extend self

  def check(filter_input)
    actor_ip = get_ip(filter_input.record, filter_input.activity.request_info)
    return filter_input.false_result if actor_ip.blank?

    if filter_input.rule.value.present?
      spam = actor_ip == filter_input.rule.value

      return filter_input.result(
        is_spam: spam,
        checked_data: { ip: actor_ip },
      )
    else
      blocked_ip_record = Spam::FilterValue.ip_filter.find_by(value: actor_ip)

      spam = blocked_ip_record.present?

      return filter_input.result(
        is_spam: spam,
        checked_data: { ip: actor_ip },
        filter_value: blocked_ip_record,
      )
    end
  end

  private

  def get_ip(activity, request_info)
    ip_from_activity(activity) || request_info&.dig(:request_ip)&.to_s
  end

  def ip_from_activity(activity)
    case activity
    when Vote
      activity.vote_info&.request_ip&.to_s
    end
  end
end
