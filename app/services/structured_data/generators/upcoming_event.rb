# frozen_string_literal: true

module StructuredData::Generators::UpcomingEvent
  extend self

  # Note(AR): An upcoming event shouldn't render any structured data, since the
  # product is not published yet. If it *was*, we'd be sharing a Product
  # instead.
  def structured_data_for(_upcoming_event)
    nil
  end
end
