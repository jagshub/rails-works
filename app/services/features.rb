# frozen_string_literal: true

module Features
  # NOTE(vesln): Presents a user without a session, necessary for the
  # "guest_user" flipper group
  class GuestUser
    def initialize(id = nil)
      @flipper_id = id
    end

    def flipper_id
      @flipper_id ||= SecureRandom.uuid
    end

    def beta_tester?
      false
    end

    def can_post?
      false
    end

    def admin?
      false
    end
  end

  class << self
    # Note (Mike Coutermarsh): Use this before making multiple `enabled?` calls.
    #
    #   Features.preload([:flag, :names, :go, :here]) # preloads flags
    #
    #   Features.enabled?(:flag, user) # will use preloaded flags!
    #
    #   It loads flags into memory (only lasts lifetime of the current request) using a single Redis trip.
    #   All subsequent calls to `enabled?` will use the cache instead of making a Redis call.
    def preload(*args)
      HandleRedisErrors.call do
        flipper.preload(*args)
      end
    end

    def enabled?(feature_name, user_or_id = nil)
      HandleRedisErrors.call(fallback: false) do
        flipper[feature_name].enabled?(user_or_id.is_a?(User) ? user_or_id : Features::GuestUser.new(user_or_id))
      end
    end

    def enabled_features(user)
      flipper.features.select do |feature|
        flipper[feature.name].enabled?(user)
      end.map(&:name)
    end

    def enable_for_user(feature_name, user)
      flipper[feature_name].enable(user)
    end

    def disable_for_user(feature_name, user)
      flipper[feature_name].disable(user)
    end

    # Note(LukasFittl): Use this when testing feature-flagged code
    def enable_for_all(feature_name)
      flipper[feature_name].enable
    end

    def disable_for_all(feature_name)
      flipper[feature_name].disable
    end

    # Note(LukasFittl): Avoid using this directly except in flipper-specific code
    def flipper
      Producthunt.flipper
    end
  end
end
