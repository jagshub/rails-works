# frozen_string_literal: true

module SpamChecks::Filters::LinkFilter
  extend self

  def check(filter_input)
    links = links_from_activity(filter_input.record)
    return filter_input.false_result if links.empty?

    if filter_input.rule.value.present?
      spam = links.include?(filter_input.rule.value)

      return filter_input.result(
        is_spam: spam,
        checked_data: { 'links' => links },
      )
    else
      matching_filter_value_record = Spam::FilterValue.link_filter.where(value: links).limit(1).first

      spam = matching_filter_value_record.present?

      return filter_input.result(
        is_spam: spam,
        checked_data: { 'links' => links },
        filter_value: matching_filter_value_record,
      )
    end
  end

  def format(value:, validate: false)
    formatted_url = UrlParser.clean_url value

    raise ArgumentError, "#{ value } is not a valid url" if validate && formatted_url.blank?

    formatted_url || value
  end

  private

  def links_from_activity(activity)
    case activity
    when Comment then
      Nokogiri::HTML(activity.body).search('a/@href').map do |match|
        format value: match.value
      end
    when User then
      url = activity.website_url

      url.present? ? [format(value: url)] : []
    else
      raise ArgumentError, "#{ activity.class.name } is not handled by the filter"
    end
  end
end
