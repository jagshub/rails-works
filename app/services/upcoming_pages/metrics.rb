# frozen_string_literal: true

module UpcomingPages::Metrics
  extend self

  # NOTE (k1): This terrible function is required because Highcharts X-axis interpolation cannot be disabled.
  def fill_missing_intervals(periods, fields = [], step = 1.day)
    return [] if periods.empty?

    all_period_dates = (periods.first[:period].to_i..periods.last[:period].to_i).step(step.to_i)

    periods_by_period_date = Hash[periods.map { |period| [period[:period].to_i, period] }]

    all_period_dates.map do |period_date|
      result = periods_by_period_date[period_date]

      if result.nil?
        result = {}

        fields.each do |field|
          result[field] = 0
        end
      end

      result[:period] = Time.at(period_date).to_datetime.utc

      result
    end
  end
end
