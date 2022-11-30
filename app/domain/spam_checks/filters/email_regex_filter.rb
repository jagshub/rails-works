# frozen_string_literal: true

module SpamChecks::Filters::EmailRegexFilter
  extend self

  def check(filter_input)
    email = email_from_activity(filter_input.record)
    return filter_input.false_result if email.blank?

    regex_string = filter_input.rule.value
    raise ArgumentError, 'regex value is not present' if regex_string.blank?

    spam = Regexp.new(regex_string).match?(email)

    filter_input.result(
      is_spam: spam,
      checked_data: { 'email' => email },
    )
  end

  private

  def email_from_activity(activity)
    case activity
    when User then
      email(activity)
    when Vote then
      email(activity.user)
    else
      raise ArgumentError, "#{ activity.class.name } is not handled by the filter"
    end
  end

  def email(user)
    user.email
  end
end
