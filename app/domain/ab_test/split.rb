# frozen_string_literal: true

module AbTest
  class Split < Split::EncapsulatedHelper::ContextShim
    attr_reader :request

    def self.from_graphql_context(ctx)
      new current_user: ctx[:current_user], visitor_id: ctx[:visitor_id], request: ctx[:request]
    end

    def initialize(current_user:, visitor_id:, request:)
      cookies = request&.cookies || {}
      @tracking_data = {
        current_user: current_user,
        visitor_id: visitor_id,
        anonymous_id: cookies['ajs_anonymous_id']&.gsub('"', ''),
      }
      @request = request

      super(current_user: current_user, visitor_id: visitor_id)
    end

    def value_from_model(test_name, variants)
      flag_name = "ab_#{ test_name }".to_sym
      user_or_visitor = @tracking_data[:current_user] || @tracking_data[:visitor_id]

      is_feature_disabled = Flipper.exist?(flag_name) && !Flipper.enabled?(flag_name, user_or_visitor)
      return variants.first if is_feature_disabled

      ab_test(test_name, *variants)
    end

    def log_new_participant(trial)
      ::AbTest::ParticipantLogWorker.perform_later(
        test_name: trial.experiment.name,
        user: @tracking_data[:current_user],
        visitor_id: @tracking_data[:visitor_id],
        anonymous_id: @tracking_data[:anonymous_id],
        variant: trial.alternative.name,
      )
    end

    def log_ab_finish(trial)
      ::AbTest::MarkTestCompletedWorker.perform_later(
        test_name: trial.experiment.name,
        user: @tracking_data[:current_user],
        visitor_id: @tracking_data[:visitor_id],
        anonymous_id: @tracking_data[:anonymous_id],
        variant: trial.alternative.name,
      )
    end

    def value_for(test_name)
      value_from_model(test_name, AbTest::TESTS.fetch(test_name))
    end
  end
end
