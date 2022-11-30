# frozen_string_literal: true

module Mobile::Graph::Mutations
  class Test < BaseMutation
    returns Boolean

    def perform
      true
    end
  end
end
