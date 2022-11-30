# frozen_string_literal: true

class Graph::Resolvers::Discussion::FindResolver < Graph::Resolvers::Base
  argument :id, ID, required: false
  argument :slug, String, required: false

  type Graph::Types::Discussion::ThreadType, null: true

  def resolve(id: nil, slug: nil)
    thread = Discussion::Thread.not_trashed.friendly.find(id || slug)

    if thread.subject_id == MakerGroup::IOS_BETA &&
       ApplicationPolicy.can?(current_user, :participate, :ios_beta)
      thread
    elsif thread.subject_id == MakerGroup::ANDROID_BETA &&
          ApplicationPolicy.can?(current_user, :participate, :android_beta)
      thread
    elsif thread.subject_id != MakerGroup::IOS_BETA &&
          thread.subject_id != MakerGroup::ANDROID_BETA
      thread
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
