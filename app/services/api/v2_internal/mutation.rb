# frozen_string_literal: true

class API::V2Internal::Mutation < API::V2Internal::Types::BaseObject
  graphql_name 'Mutation'

  field :vote_create, mutation: API::V2Internal::Mutations::VoteCreate
  field :vote_destroy, mutation: API::V2Internal::Mutations::VoteDestroy

  field :comment_create, mutation: API::V2Internal::Mutations::CommentCreate
  field :comment_destroy, mutation: API::V2Internal::Mutations::CommentDestroy
  field :comment_update, mutation: API::V2Internal::Mutations::CommentUpdate
  field :comment_reply, mutation: API::V2Internal::Mutations::CommentReply

  field :collection_add_post, mutation: API::V2Internal::Mutations::CollectionAddPost
  field :collection_remove_post, mutation: API::V2Internal::Mutations::CollectionRemovePost
  field :collection_post_save_for_later, mutation: API::V2Internal::Mutations::CollectionPostSaveForLater
  field :collection_remove_saved_for_later_post, mutation: API::V2Internal::Mutations::CollectionRemoveSavedForLaterPost
  field :collection_create, mutation: API::V2Internal::Mutations::CollectionCreate
  field :collection_destroy, mutation: API::V2Internal::Mutations::CollectionDestroy

  field :user_activities_last_seen_update, mutation: API::V2Internal::Mutations::UserActivitiesLastSeenUpdate
  field :user_confirm_age, mutation: API::V2Internal::Mutations::UserConfirmAge
  field :user_follow, mutation: API::V2Internal::Mutations::UserFollow
  field :user_unfollow, mutation: API::V2Internal::Mutations::UserUnfollow
  field :user_onboarding_settings_update, mutation: API::V2Internal::Mutations::UserOnboardingSettingsUpdate

  field :update_user_settings, mutation: API::V2Internal::Mutations::UpdateSettings

  field :notification_token_create, mutation: API::V2Internal::Mutations::NotificationTokenCreate

  field :poll_answer_create, mutation: API::V2Internal::Mutations::PollAnswerCreate
  field :pollanswerdestroy, mutation: API::V2Internal::Mutations::PollAnswerDestroy

  field :ads_interaction_create, mutation: API::V2Internal::Mutations::AdsInteractionCreate

  field :promoted_email_signup_create, mutation: API::V2Internal::Mutations::PromotedEmailSignupCreate

  field :flag_create, mutation: API::V2Internal::Mutations::FlagCreate
end
