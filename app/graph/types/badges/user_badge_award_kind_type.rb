# frozen_string_literal: true

module Graph::Types
  class Badges::UserBadgeAwardKindType < BaseEnum
    ::Badges::Award.identifiers.keys.each do |id|
      value id
    end
  end
end
