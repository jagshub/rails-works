# frozen_string_literal: true

module Graph::Types
  class SpamLevelsEnum < BaseEnum
    value 'QUESTIONABLE'
    value 'INAPPROPRIATE'
    value 'SPAMMER'
    value 'HARMFUL'
  end
end
