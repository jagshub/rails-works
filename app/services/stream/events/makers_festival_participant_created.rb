# frozen_string_literal: true

module Stream
  class Events::MakersFestivalParticipantCreated < Events::Base
    allowed_subjects [MakersFestival::Participant]
    fanout_workers { |_event| [Stream::Activities::MakersFestivalParticipantAdded] }
  end
end
