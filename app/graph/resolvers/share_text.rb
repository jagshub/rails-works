# frozen_string_literal: true

class Graph::Resolvers::ShareText < Graph::Resolvers::Base
  argument :subject_id, ID, required: false
  argument :subject_type, String, required: false

  type String, null: true

  def resolve(subject_id: nil, subject_type: nil)
    subject = Sharing.find_subject(subject_type, subject_id)
    Sharing.text_for(subject, user: current_user)
  end
end
