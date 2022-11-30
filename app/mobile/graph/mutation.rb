# frozen_string_literal: true

class Mobile::Graph::Mutation < Mobile::Graph::Types::BaseObject
  graphql_name 'Mutation'

  def self.mutation_field(mutation_class, deprecation_reason: nil)
    field mutation_class.name.demodulize.underscore, mutation: mutation_class, deprecation_reason: deprecation_reason
  end
  mutation_field Mobile::Graph::Mutations::SignIn
  mutation_field Mobile::Graph::Mutations::SignInMerge

  mutation_field Mobile::Graph::Mutations::CollectionCreate
  mutation_field Mobile::Graph::Mutations::CollectionUpdate
  mutation_field Mobile::Graph::Mutations::CollectionFollow
  mutation_field Mobile::Graph::Mutations::CollectionUnfollow
  mutation_field Mobile::Graph::Mutations::CollectionDestroy
  mutation_field Mobile::Graph::Mutations::CollectionPostAdd
  mutation_field Mobile::Graph::Mutations::CollectionPostSet
  mutation_field Mobile::Graph::Mutations::CollectionPostRemove

  mutation_field Mobile::Graph::Mutations::CollectionProductAdd
  mutation_field Mobile::Graph::Mutations::CollectionProductRemove
  mutation_field Mobile::Graph::Mutations::CollectionProductSet

  mutation_field Mobile::Graph::Mutations::DiscussionThreadCreate
  mutation_field Mobile::Graph::Mutations::DiscussionThreadUpdate
  mutation_field Mobile::Graph::Mutations::DiscussionThreadDestroy

  mutation_field Mobile::Graph::Mutations::CommentCreate
  mutation_field Mobile::Graph::Mutations::CommentUpdate
  mutation_field Mobile::Graph::Mutations::CommentDestroy
  mutation_field Mobile::Graph::Mutations::CommentReply

  mutation_field Mobile::Graph::Mutations::VoteCreate
  mutation_field Mobile::Graph::Mutations::VoteDestroy

  mutation_field Mobile::Graph::Mutations::SettingsUpdate

  mutation_field Mobile::Graph::Mutations::TopicFollow
  mutation_field Mobile::Graph::Mutations::TopicUnfollow

  mutation_field Mobile::Graph::Mutations::UploadMedia

  mutation_field Mobile::Graph::Mutations::UserDestroy

  mutation_field Mobile::Graph::Mutations::UserEmailVerificationSend
  mutation_field Mobile::Graph::Mutations::UserEmailConfirm
  mutation_field Mobile::Graph::Mutations::UserFollow
  mutation_field Mobile::Graph::Mutations::UserOnboardingUpdate
  mutation_field Mobile::Graph::Mutations::UserUnfollow

  mutation_field Mobile::Graph::Mutations::UserLinkCreate
  mutation_field Mobile::Graph::Mutations::UserLinkDestroy
  mutation_field Mobile::Graph::Mutations::UserLinkUpdate

  mutation_field Mobile::Graph::Mutations::AdsInteractionCreate
  mutation_field Mobile::Graph::Mutations::FlagCreate

  mutation_field Mobile::Graph::Mutations::DeviceSettingUpdate
  mutation_field Mobile::Graph::Mutations::DeviceSignOut
  mutation_field Mobile::Graph::Mutations::DevicePushNotificationsTokenRegister

  mutation_field Mobile::Graph::Mutations::VisitStreakUpdate

  mutation_field Mobile::Graph::Mutations::ProductFollow, deprecation_reason: 'use ProductSubscribe instead'
  mutation_field Mobile::Graph::Mutations::ProductUnfollow, deprecation_reason: 'use ProductUnsubscribe instead'
  mutation_field Mobile::Graph::Mutations::ProductSubscribe
  mutation_field Mobile::Graph::Mutations::ProductUnsubscribe
  mutation_field Mobile::Graph::Mutations::ProductMute
  mutation_field Mobile::Graph::Mutations::ProductUnmute

  mutation_field Mobile::Graph::Mutations::AbTestComplete

  mutation_field Mobile::Graph::Mutations::NotificationEventUpdate
end
