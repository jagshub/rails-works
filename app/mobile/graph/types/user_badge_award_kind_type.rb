# frozen_string_literal: true

module Mobile::Graph::Types
  class UserBadgeAwardKindType < BaseEnum
    ::Badges::Award.identifiers.keys.each do |id|
      value id
    end
  end
end
