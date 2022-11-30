# frozen_string_literal: true

module Search::Query::Utils::Helpers
  extend self

  def date_key_to_time(date_key)
    case date_key
    when '7:days'
      7.days.ago
    when '30:days'
      30.days.ago
    when '90:days'
      90.days.ago
    when '12:months'
      12.months.ago
    end
  end
end
