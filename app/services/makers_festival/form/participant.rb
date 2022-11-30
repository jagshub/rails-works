# frozen_string_literal: true

class MakersFestival::Form::Participant
  include MiniForm::Model

  PARAMS = %i(
    project_name
    project_tagline
    project_thumbnail
    external_link
    makers_festival_category_id
    maker_ids
    user_id
    snapchat_app_id
    snapchat_app_video_link
    snapchat_username
    receive_tc_resources
  ).freeze

  model :participant, attributes: PARAMS, read: %i(id), save: true

  attr_reader :request_info

  validates :maker_ids, presence: true, length: { maximum: 20, message: 'maximum 20 makers allowed' }
  validates :makers_festival_category_id, presence: true
  validates :user_id, presence: true

  with_options if: :submission? do
    validates :project_name, presence: true
    validates :project_tagline, presence: true, length: { maximum: 64 }
    validates :project_thumbnail, presence: true
    validates :external_link, presence: true, format: URI.regexp(['http', 'https'])
  end

  after_update :add_makers_to_maker_group
  after_update :notify_participants_friends

  alias node participant
  alias graphql_result participant

  def initialize(participant: nil, phase: 'registration', request_info: {})
    @participant = participant || ::MakersFestival::Participant.new
    @phase = phase
    @request_info = request_info
    @participant_is_new = @participant.new_record?
  end

  private

  def submission?
    @phase == 'submission'
  end

  def add_makers_to_maker_group
    maker_group = participant.makers_festival_category.makers_festival_edition.maker_group
    return if maker_group.blank?

    maker_ids.each { |maker_id| ::MakersFestival::MakerGroup.add_member group: maker_group, user: ::User.find(maker_id) }
  end

  def trigger_new_participant_event
    return unless @participant_is_new

    Stream::Events::MakersFestivalParticipantCreated.trigger(
      user: participant.user,
      subject: participant,
      source: :web,
      request_info: request_info,
    )
  end

  def notify_participants_friends
    return unless @participant_is_new

    festival = participant.makers_festival_category.makers_festival_edition
    return if festival.registration.blank? || festival.registration.future?
    return if festival.registration_ended.blank? || festival.registration_ended.past?

    MakersFestival::NotifyFriendsWorker.perform_later(participant: participant)
  end
end
