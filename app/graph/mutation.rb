# frozen_string_literal: true

class Graph::Mutation < Graph::Types::BaseObject
  graphql_name 'Mutation'

  def self.mutation_field(mutation_class)
    field mutation_class.name.demodulize.underscore, mutation: mutation_class
  end

  mutation_field Graph::Mutations::UserCookiePolicyAccept

  mutation_field Graph::Mutations::CommentCreate
  mutation_field Graph::Mutations::CommentUpdate
  mutation_field Graph::Mutations::CommentDestroy
  mutation_field Graph::Mutations::CommentReply

  mutation_field Graph::Mutations::PostItemViewsTrack
  mutation_field Graph::Mutations::PostDraftCreate
  mutation_field Graph::Mutations::PostDraftUpdate
  mutation_field Graph::Mutations::PostDraftDestroy

  mutation_field Graph::Mutations::VoteCreate
  mutation_field Graph::Mutations::VoteDestroy

  mutation_field Graph::Mutations::AbTestComplete

  mutation_field Graph::Mutations::CollectionCreate
  mutation_field Graph::Mutations::CollectionCreateWithProduct
  mutation_field Graph::Mutations::CollectionUpdate
  mutation_field Graph::Mutations::CollectionDestroy
  mutation_field Graph::Mutations::CollectionProductRemove
  mutation_field Graph::Mutations::CollectionProductAdd
  # TODO(DZ): Remove after collection move to products
  mutation_field Graph::Mutations::CollectionAddPost
  mutation_field Graph::Mutations::CollectionRemovePost

  mutation_field Graph::Mutations::DiscussionThreadCreate

  mutation_field Graph::Mutations::ModerationCommentHide
  mutation_field Graph::Mutations::ModerationDuplicatePostRequestCreate
  mutation_field Graph::Mutations::ModerationDuplicatePostRequestAction
  mutation_field Graph::Mutations::ModerationCommentUnhide
  mutation_field Graph::Mutations::ModerationReviewHide
  mutation_field Graph::Mutations::ModerationReviewUnhide
  mutation_field Graph::Mutations::ModerationDiscussionThreadApprove
  mutation_field Graph::Mutations::ModerationDiscussionThreadFeature
  mutation_field Graph::Mutations::ModerationDiscussionThreadHide
  mutation_field Graph::Mutations::ModerationDiscussionThreadMarkAsTrending
  mutation_field Graph::Mutations::ModerationDiscussionThreadReject
  mutation_field Graph::Mutations::ModerationDiscussionThreadSetPinned
  mutation_field Graph::Mutations::ModerationDiscussionThreadUnfeature
  mutation_field Graph::Mutations::ModerationDiscussionThreadUnhide
  mutation_field Graph::Mutations::ModerationDiscussionThreadUnmarkAsTrending
  mutation_field Graph::Mutations::ModerationNodeReview
  mutation_field Graph::Mutations::ModerationFlagResolve
  mutation_field Graph::Mutations::ModerationNodeSeoReview
  mutation_field Graph::Mutations::ModerationUpcomingEventAction

  mutation_field Graph::Mutations::ModerationPostReview
  mutation_field Graph::Mutations::ModerationPostTrash
  mutation_field Graph::Mutations::ModerationPostUpdate
  mutation_field Graph::Mutations::ModerationPostUpdateProduct

  mutation_field Graph::Mutations::ModerationProductUpdate
  mutation_field Graph::Mutations::ModerationProductSkip
  mutation_field Graph::Mutations::ModerationProductApprove
  mutation_field Graph::Mutations::ModerationProductMarkAsOffline

  mutation_field Graph::Mutations::ModerationProductAssociationCreate
  mutation_field Graph::Mutations::ModerationProductAssociationDestroy
  mutation_field Graph::Mutations::ModerationProductAssociationUpdate

  mutation_field Graph::Mutations::ModerationUserMarkAsCompany
  mutation_field Graph::Mutations::ModerationUserMarkAsBadActor
  mutation_field Graph::Mutations::ModerationUserMarkAsSpammer

  mutation_field Graph::Mutations::ModerationTeamRequestNotesUpdate

  mutation_field Graph::Mutations::PostCreate
  mutation_field Graph::Mutations::PostUpdate
  mutation_field Graph::Mutations::PostBecomeMaker

  mutation_field Graph::Mutations::SubscribeJobsNewsletter

  mutation_field Graph::Mutations::GoalsExport

  mutation_field Graph::Mutations::FlagCreate

  mutation_field Graph::Mutations::ProfileHeaderSync
  mutation_field Graph::Mutations::AvatarSync
  mutation_field Graph::Mutations::Dismiss
  mutation_field Graph::Mutations::SubscriberEmailConfirm
  mutation_field Graph::Mutations::SubscriberEmailVerificationSend

  mutation_field Graph::Mutations::UpcomingPageConfirmSubscription

  mutation_field Graph::Mutations::UpcomingPageCreate
  mutation_field Graph::Mutations::UpdateUpcomingPage
  mutation_field Graph::Mutations::UpcomingPageDestroy
  mutation_field Graph::Mutations::UpcomingPageBuild
  mutation_field Graph::Mutations::UpcomingPageChangeStatus

  mutation_field Graph::Mutations::UpcomingEventUpdateActive
  mutation_field Graph::Mutations::UpcomingEventCreate
  mutation_field Graph::Mutations::UpcomingEventUpdate

  mutation_field Graph::Mutations::UserBadgeShowcaseAdd
  mutation_field Graph::Mutations::UserBadgeShowcaseRemove

  mutation_field Graph::Mutations::CreateUpcomingPageSubscriber
  mutation_field Graph::Mutations::DestroyUpcomingPageSubscriber

  mutation_field Graph::Mutations::SaveUpcomingPageSubscriberSearch
  mutation_field Graph::Mutations::DestroyUpcomingPageSubscriberSearch

  mutation_field Graph::Mutations::SaveUpcomingPageSurvey

  mutation_field Graph::Mutations::SaveUpcomingPageQuestion
  mutation_field Graph::Mutations::MoveUpcomingPageQuestion
  mutation_field Graph::Mutations::DestroyUpcomingPageQuestion

  mutation_field Graph::Mutations::SaveUpcomingPageQuestionAnswer
  mutation_field Graph::Mutations::DestroyUpcomingPageSurvey

  mutation_field Graph::Mutations::DestroyUpcomingPageConversation

  mutation_field Graph::Mutations::SendConversationMessage

  mutation_field Graph::Mutations::CreateUpcomingPageMessage
  mutation_field Graph::Mutations::UpdateUpcomingPageMessage
  mutation_field Graph::Mutations::DestroyUpcomingPageMessage
  mutation_field Graph::Mutations::MarkMessageResponsesAsSeen

  mutation_field Graph::Mutations::CreateUpcomingPageSegment
  mutation_field Graph::Mutations::UpdateUpcomingPageSegment
  mutation_field Graph::Mutations::SegmentAddSubscriber
  mutation_field Graph::Mutations::RemoveSubscriberFromSegment
  mutation_field Graph::Mutations::DestroyUpcomingPageSegment

  mutation_field Graph::Mutations::AddUpcomingPageSubscriber

  mutation_field Graph::Mutations::UploadMedia
  mutation_field Graph::Mutations::ImportUpcomingPageSubscribers

  mutation_field Graph::Mutations::ReviewCreate
  mutation_field Graph::Mutations::ReviewUpdate
  mutation_field Graph::Mutations::ReviewDestroy

  mutation_field Graph::Mutations::ShipTrackEventCreate
  mutation_field Graph::Mutations::ShipSubscriptionCreate
  mutation_field Graph::Mutations::ShipTrialCreate
  mutation_field Graph::Mutations::ShipSubscriptionCancel
  mutation_field Graph::Mutations::ApplyShipInviteCode

  mutation_field Graph::Mutations::ShipContactDestroy

  mutation_field Graph::Mutations::UserDestroy

  mutation_field Graph::Mutations::SkuPurchase
  mutation_field Graph::Mutations::JobPurchase
  mutation_field Graph::Mutations::ShipLeadSave
  mutation_field Graph::Mutations::ShipLeadUpdate

  mutation_field Graph::Mutations::ShipAwsApplicationSave

  mutation_field Graph::Mutations::SlackBotDestroy

  mutation_field Graph::Mutations::UpcomingPageSubscribersExport
  mutation_field Graph::Mutations::ShipSurveyResultsExport

  mutation_field Graph::Mutations::ShipAccountUpdate

  mutation_field Graph::Mutations::ShipStripeDiscountRequest

  mutation_field Graph::Mutations::NewsletterSubscriptionCreate

  mutation_field Graph::Mutations::NotificationSubscriptionDestroy

  mutation_field Graph::Mutations::OnboardingUserSettingsUpdate
  mutation_field Graph::Mutations::SettingsUpdate
  mutation_field Graph::Mutations::OnboardingUserReasonCreate
  mutation_field Graph::Mutations::UserCryptoWalletDestroy

  mutation_field Graph::Mutations::JobSave
  mutation_field Graph::Mutations::JobCancel

  mutation_field Graph::Mutations::MakerFestVoteCreate
  mutation_field Graph::Mutations::MakerFestVoteDestroy

  mutation_field Graph::Mutations::MakersFestivalRegister
  mutation_field Graph::Mutations::MakersFestivalSubmitProduct

  mutation_field Graph::Mutations::ShoutoutCreate
  mutation_field Graph::Mutations::UserVerify

  mutation_field Graph::Mutations::GoldenKittyNominationCreate
  mutation_field Graph::Mutations::GoldenKittyNominationsCreate
  mutation_field Graph::Mutations::GoldenKittyNominationDestroy
  mutation_field Graph::Mutations::GoldenKittyNominationCommentCreate
  mutation_field Graph::Mutations::GoldenKittyVoteCreate
  mutation_field Graph::Mutations::GoldenKittyVoteDestroy

  mutation_field Graph::Mutations::UserFollowCreate
  mutation_field Graph::Mutations::UserFollowDestroy
  mutation_field Graph::Mutations::UserFollowCreateBulk
  mutation_field Graph::Mutations::UserFollowDestroyBulk

  mutation_field Graph::Mutations::StoryNewsletterSubscriptionCreate
  mutation_field Graph::Mutations::StoryCreate
  mutation_field Graph::Mutations::StoryUpdate

  mutation_field Graph::Mutations::PaymentSubscriptionCreate
  mutation_field Graph::Mutations::PaymentSubscriptionCancel

  mutation_field Graph::Mutations::FounderClubDealClaim
  mutation_field Graph::Mutations::FounderClubInviteCodeEnter
  mutation_field Graph::Mutations::FounderClubReferralCreate
  mutation_field Graph::Mutations::FounderClubReferralDestroy

  mutation_field Graph::Mutations::DiscussionThreadDestroy
  mutation_field Graph::Mutations::DiscussionThreadUpdate
  mutation_field Graph::Mutations::DestroyStructuredDataValidationMessage

  mutation_field Graph::Mutations::BrowserExtensionSettingsUpdate

  mutation_field Graph::Mutations::PollAnswerCreate
  mutation_field Graph::Mutations::PollAnswerDestroy

  mutation_field Graph::Mutations::ViewerNotificationsLastSeenUpdate
  mutation_field Graph::Mutations::ViewerPushTokenRegister

  mutation_field Graph::Mutations::NotificationInteractionSave

  mutation_field Graph::Mutations::StripeCardUpdate
  mutation_field Graph::Mutations::StripeSubscriptionCreate

  mutation_field Graph::Mutations::AdsInteractionCreate
  mutation_field Graph::Mutations::AdsNewsletterOpen
  mutation_field Graph::Mutations::NewSocialLoginSeparate

  mutation_field Graph::Mutations::VisitStreakUpdate

  mutation_field Graph::Mutations::ProductUpdate
  mutation_field Graph::Mutations::ProductReviewSuggestionSkip

  mutation_field Graph::Mutations::UserLinkCreate
  mutation_field Graph::Mutations::UserLinkUpdate
  mutation_field Graph::Mutations::UserLinkDestroy

  # NOTE(DZ): Collections uses `CollectionSubscription` model, should be refactored
  # into `Subscription` model.
  mutation_field Graph::Mutations::CollectionFollow
  mutation_field Graph::Mutations::CollectionUnfollow

  mutation_field Graph::Mutations::SubscriptionCreate
  mutation_field Graph::Mutations::SubscriptionDestroy
  mutation_field Graph::Mutations::SubscriptionGoldenKittyCreate
  mutation_field Graph::Mutations::SubscriptionMute
  mutation_field Graph::Mutations::SubscriptionTopicFollow
  mutation_field Graph::Mutations::SubscriptionTopicUnfollow
  mutation_field Graph::Mutations::SubscriptionUnmute

  mutation_field Graph::Mutations::TeamMemberRoleUpdate
  mutation_field Graph::Mutations::TeamMemberStatusUpdate
  mutation_field Graph::Mutations::TeamInviteCreate
  mutation_field Graph::Mutations::TeamInviteAccept
  mutation_field Graph::Mutations::TeamInviteReject
  mutation_field Graph::Mutations::TeamInviteResend
  mutation_field Graph::Mutations::TeamInviteDestroy
  mutation_field Graph::Mutations::TeamRequestCreate
  mutation_field Graph::Mutations::TeamRequestApprove
  mutation_field Graph::Mutations::TeamRequestReject
  mutation_field Graph::Mutations::TeamRequestEmailConfirm
  mutation_field Graph::Mutations::TeamRequestEmailResend

  # Stacks
  mutation_field Graph::Mutations::ProductStackAdd
  mutation_field Graph::Mutations::ProductStackRemove
  mutation_field Graph::Mutations::ProductSuggestAlternative
end
