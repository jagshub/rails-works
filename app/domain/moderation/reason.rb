# frozen_string_literal: true

module Moderation
  module Reason
    extend self

    def find_by(reference:, share_public: nil)
      # Note(LukasFittl): Only unfeatured posts have moderation reasons, also in the
      #   case of re-featuring we don't clear the old one, so we need this check.
      return if reference.is_a?(Post) && reference.featured?

      scope = reference.moderation_logs
      scope = scope.share_public if share_public
      scope.last
    end

    # NOTE(andreasklinger): We want to easy enable users to update old moderation logs.
    #   This is hacky. We should have a moderation state and keep the log more as a
    #   generic log that just happens on the side.
    #   If you find yourself needing to make this more complex consider switching the structure.
    def find_or_initialize_by(reference:, moderator:)
      ModerationLog.new values_of_last_moderation_log(reference, moderator)
    end

    private

    def values_of_last_moderation_log(reference, moderator)
      last = find_by(reference: reference)
      return base_attributes(reference, moderator) if last.blank?

      base_attributes(reference, moderator).merge reason: last.reason, share_public: last.share_public
    end

    def base_attributes(reference, moderator)
      { reference: reference, moderator: moderator }
    end
  end
end
