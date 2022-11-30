# frozen_string_literal: true

module GoldenKitty::Hof
  extend self

  Hof = Struct.new(:years, :edition)

  def call(year = nil)
    editions = GoldenKitty::Edition
      .where_time_lteq(:result_at, Time.zone.now)
      .order(year: :desc)
      .to_a

    edition = if year.present?
                editions.find { |e| e.year == year }
              else
                editions.first
              end
    years = editions.map(&:year)

    Hof.new(years, edition)
  end
end
