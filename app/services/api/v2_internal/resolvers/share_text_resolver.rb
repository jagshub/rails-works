# frozen_string_literal: true

class API::V2Internal::Resolvers::ShareTextResolver < Graph::Resolvers::Base
  argument :subjectId, ID, required: false
  argument :subjectType, String, required: false

  type String, null: true

  def resolve(**args)
    subject = Sharing.find_subject(args[:subject_type], args[:subject_id])
    Sharing.text_for(subject, user: current_user)
  end
end
