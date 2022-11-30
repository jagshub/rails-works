# frozen_string_literal: true

module SpamChecks::Filters::DomainFilter
  extend self

  def check(filter_input)
    domains = domains_from_activity(filter_input.record)
    return filter_input.false_result if domains.empty?

    checked_data = { 'domains' => domains }

    if filter_input.rule.value.present?
      spam = domains.include?(filter_input.rule.value)

      return filter_input.result(
        is_spam: spam,
        checked_data: checked_data,
      )
    else
      matching_filter_value_record = Spam::FilterValue.domain_filter.where(value: domains).limit(1).first
      spam = matching_filter_value_record.present?

      return filter_input.result(
        is_spam: spam,
        checked_data: checked_data,
        filter_value: matching_filter_value_record,
      )
    end
  end

  def format(value:, validate: false)
    formatted_url = UrlParser.clean_url value
    domain = formatted_url&.split('/')&.first

    raise ArgumentError, "#{ value } is not a valid domain" if validate && domain.blank?

    domain || value
  end

  private

  def domains_from_activity(activity)
    case activity
    when Comment then
      Nokogiri::HTML(activity.body).search('a/@href').map do |match|
        format value: match.value
      end
    when User then
      get_email_domain(activity.email)
    when Vote then
      get_email_domain(activity.user.email)
    else
      raise ArgumentError, "#{ activity.class.name } is not handled by the filter"
    end
  end

  def get_email_domain(email)
    domain = email&.split('@')&.second

    domain.present? ? [format(value: domain)] : []
  end
end
