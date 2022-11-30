# frozen_string_literal: true

module Graph::Mutations
  class MakersFestivalRegister < BaseMutation
    argument_record :participant, ::MakersFestival::Participant, authorize: :update_participant, required: false
    argument :maker_ids, [ID], required: true
    argument :agreement, Boolean, required: true
    argument :receive_tc_resources, Boolean, required: false
    argument :makers_festival_category_id, ID, required: false

    returns Graph::Types::MakersFestival::ParticipantType

    require_current_user

    def perform(participant: nil, **inputs)
      return error :agreement, 'should accept!' unless inputs[:agreement]

      form = ::MakersFestival::Form::Participant.new(
        participant: participant,
        phase: 'registration',
        request_info: request_info,
      )

      form.update(
        inputs.merge(
          maker_ids: (inputs[:maker_ids] || []).push(current_user.id.to_s).uniq,
          user_id: current_user.id,
        ),
      )
      form
    end
  end
end
