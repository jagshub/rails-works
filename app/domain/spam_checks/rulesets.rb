# frozen_string_literal: true

module SpamChecks::Rulesets
  extend self

  def get_for_activity(activity)
    rulesets =
      Spam::Ruleset
      .where(
        active: true,
        for_activity: activity_key(activity),
      )
      .includes(:rules)
      .by_priority

    rulesets
  end

  private

  def activity_key(activity)
    key = activity.class.model_name.singular

    raise ArgumentError, "#{ key } is not present in Spam::Ruleset.for_activities" unless ::Spam::Ruleset.for_activities.key? key

    key
  end
end
