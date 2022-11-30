# frozen_string_literal: true

module Mobile::Graph::Types
  class ViewerType < BaseNode
    field :user, Mobile::Graph::Types::UserType, null: false
    field :is_admin, Boolean, null: false, resolver_method: :admin?
    field :confirmed_age, Boolean, null: false
    field :settings, Mobile::Graph::Types::SettingsType, null: true
    field :onboarding, Mobile::Graph::Types::OnboardingsType, null: false
    field :is_onboarded, Boolean, null: false, resolver_method: :onboarded?
    field :analytics_identify_json, Mobile::Graph::Types::JsonType, null: false
    field :email_verified, Boolean, null: false, resolver_method: :email_verified?

    # NOTE(DZ): Temporary beta fields
    field :in_ios_beta, resolver: Mobile::Graph::Utils::CanResolver.build(:participate) { :ios_beta }
    field :in_android_beta, resolver: Mobile::Graph::Utils::CanResolver.build(:participate) { :android_beta }

    field :device, Mobile::Graph::Types::DeviceType, null: true

    field :visit_streak_duration, Int, null: false, deprecation_reason: 'Use streak, which includes duration, emoji and text to display'
    field :streak, Mobile::Graph::Types::StreakType, null: false

    def user
      object
    end

    def admin?
      object.id == current_user&.id && object.admin?
    end

    def onboarding
      current_user.onboardings.mobile.first || current_user.onboardings.mobile.new(step: 0)
    end

    def onboarded?
      current_user.onboardings.completed.where(name: %i(mobile user_signup)).blank? ? false : true
    end

    def settings
      My::UserSettings.new(current_user) if current_user.present?
    end

    def analytics_identify_json
      return {} unless logged_in?

      Metrics.super_properties(current_user)
    end

    def logged_in?
      !!context[:current_user]
    end

    def device
      Mobile::Device.device_for(user: current_user, request: context[:request])
    end

    def visit_streak_duration
      ::UserVisitStreak.visit_streak_duration(current_user)
    end

    def streak
      ::UserVisitStreak.streak_info(current_user)
    end

    def email_verified?
      current_user&.verified? || false
    end
  end
end
