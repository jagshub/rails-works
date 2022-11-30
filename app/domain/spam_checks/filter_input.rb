# frozen_string_literal: true

class SpamChecks::FilterInput
  attr_reader :activity, :rule

  delegate :record, to: :activity

  def initialize(activity, rule)
    @activity = activity
    @rule = rule
  end

  def result(is_spam:, checked_data:, filter_value: nil)
    Result.new(checked_data, is_spam, filter_value)
  end

  def false_result
    Result.new({}, false, nil)
  end

  class Result
    attr_reader :checked_data, :filter_value

    def initialize(checked_data, spam, filter_value)
      @checked_data = checked_data
      @filter_value = filter_value
      @spam = spam
    end

    def spam?
      @spam
    end
  end

  private_constant :Result
end
