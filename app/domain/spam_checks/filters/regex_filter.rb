# frozen_string_literal: true

module SpamChecks::Filters::RegexFilter
  extend self

  def check(filter_input)
    content = content_from_activity(filter_input.record)
    return filter_input.false_result if content.blank?

    regex_string = filter_input.rule.value
    raise ArgumentError, 'regex value is not present' if regex_string.blank?

    spam = Regexp.new(regex_string).match?(content)

    filter_input.result(
      is_spam: spam,
      checked_data: {
        content: content,
        filter_value: regex_string,
      },
    )
  end

  private

  def content_from_activity(activity)
    case activity.class.name
    when 'Review', 'Comment'
      activity.body
    else
      raise ArgumentError, "#{ activity.class.name } is not handled by the filter"
    end
  end
end
