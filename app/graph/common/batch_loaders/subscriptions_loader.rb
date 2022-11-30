# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class SubscriptionsLoader < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(subjects)
      subscriptions =
        @user
        .subscriptions
        .where(condition_for(subjects))
        .pluck(Arel.sql('subject_id || subject_type'))

      subjects.each do |subject|
        fulfill subject, subscriptions.include?("#{ subject.id }#{ type_to_model(subject.class.name) }")
      end
    end

    private

    def condition_for(subjects)
      values = subjects.map do |subject|
        "(#{ ActiveRecord::Base.connection.quote(type_to_model(subject.class.name)) }, #{ subject.id.to_i })"
      end
      "(subject_type, subject_id) IN ( VALUES #{ values.join(', ') } )"
    end

    def type_to_model(type)
      if type.include?('ThreadType')
        Discussion::Thread.name
      elsif type.include?('GoldenKittyEditionType')
        GoldenKitty::Edition.name
      else
        type
      end
    end
  end
end
