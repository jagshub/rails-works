# frozen_string_literal: true

module SpamChecks::Filter
  extend self

  # Note(Rahul): When you add new filter below make sure to add spec for it
  FILTER_MAP = {
    ip_filter: SpamChecks::Filters::IpFilter,
    email_regex_filter: SpamChecks::Filters::EmailRegexFilter,
    link_filter: SpamChecks::Filters::LinkFilter,
    domain_filter: SpamChecks::Filters::DomainFilter,
    custom_vote_filter: SpamChecks::Filters::CustomVoteFilter,
    regex_filter: SpamChecks::Filters::RegexFilter,
    new_user_filter: SpamChecks::Filters::NewUserFilter,
  }.freeze

  MODEL_FILTER_ENUMS = {
    ip_filter: 0,
    email_regex_filter: 1,
    link_filter: 2,
    domain_filter: 3,
    custom_vote_filter: 4,
    regex_filter: 5,
    new_user_filter: 6,
  }.freeze

  def model_enums
    MODEL_FILTER_ENUMS
  end

  def result(activity, rule)
    filter = FILTER_MAP[rule.filter_kind.to_sym]
    filter_input = SpamChecks::FilterInput.new(activity, rule)

    filter.check filter_input
  end

  def format_filter_value(filter, value)
    filter = FILTER_MAP[filter.to_sym]

    filter.respond_to?(:format) ? filter.format(value: value, validate: true) : value
  end

  def report_reason(action_log)
    action_log.rule_logs.map do |rule_log|
      filter = FILTER_MAP[rule_log.rule.filter_kind.to_sym]

      if filter&.respond_to?(:readable_check_data)
        filter.readable_check_data(rule_log)
      else
        readable_check_data(rule_log)
      end
    end.join(', ')
  end

  private

  def readable_check_data(rule_log)
    checked, checked_data = rule_log.checked_data.to_a.flatten

    "Checked #{ checked }, '#{ checked_data }' with #{ rule_log.rule.filter_kind } filter"
  end
end
