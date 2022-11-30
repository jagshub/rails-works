# frozen_string_literal: true

module Graph::Types
  class HomefeedKindEnum < BaseEnum
    Homefeed::ALL.each do |kind|
      value kind
    end
  end
end
