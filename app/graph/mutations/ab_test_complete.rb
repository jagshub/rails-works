# frozen_string_literal: true

module Graph::Mutations
  class AbTestComplete < BaseMutation
    argument :test_name, String, required: true
    argument :reset, Boolean, required: false

    def perform(test_name:, reset: true)
      AbTest.finish_test_for_participant(
        test: test_name,
        ctx: context,
        reset: reset,
      )

      success
    end
  end
end
