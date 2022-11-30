# frozen_string_literal: true

module Graph::Mutations
  class MakersFestivalSubmitProduct < BaseMutation
    argument_record :participant, ::MakersFestival::Participant, authorize: :update_participant, required: false
    argument :agreement, Boolean, required: true
    argument :external_link, String, required: false
    argument :snapchat_app_id, String, required: false
    argument :snapchat_app_video_link, String, required: false
    argument :snapchat_username, String, required: false
    argument :project_name, String, required: false
    argument :project_tagline, String, required: false
    argument :project_thumbnail, Graph::Types::MediaInputType, required: false
    argument :maker_ids, [ID], required: true
    argument :makers_festival_category_id, ID, required: false
    argument :receive_tc_resources, Boolean, required: false

    returns Graph::Types::MakersFestival::ParticipantType

    require_current_user

    def perform(participant: nil, **inputs)
      return error :agreement, 'should accept!' unless inputs[:agreement]

      form = ::MakersFestival::Form::Participant.new(participant: participant, phase: 'submission')

      form.update(
        inputs.merge(
          maker_ids: (inputs[:maker_ids] || []).push(current_user.id.to_s).uniq,
          user_id: current_user.id,
          project_thumbnail: inputs.dig(:project_thumbnail, :image_uuid),
        ),
      )
      form
    end
  end
end
