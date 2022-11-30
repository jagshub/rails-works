# frozen_string_literal: true

module Metrics::Newsletter::Formatter
  extend self

  def call(data)
    data_with_ids = extract_ids(data)

    return data_with_ids unless block_given?

    newsletters = Newsletter.where(id: data_with_ids.keys)

    data_with_ids.inject([]) do |acc, (id, campaign)|
      newsletter = newsletters.detect { |n| n.id == id.to_i }

      acc << yield(campaign, newsletter)
    end
  end

  private

  def extract_ids(data)
    data.inject({}) do |acc, campaign|
      id = extract_id(campaign.title)

      acc[id] = campaign if id && !campaign.subject.include?('TEST')
      acc
    end
  end

  def extract_id(title)
    match = title.match(/\((?![0])(\d{1,})\)/)

    # Note (Josh) we are returning false here so we can skip them on the next pass
    match.nil? ? false : match[1]
  end
end
