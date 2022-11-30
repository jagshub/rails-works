# frozen_string_literal: true

class Mobile::Graph::Resolvers::Discussions::Find < Mobile::Graph::Resolvers::BaseResolver
  argument :id, ID, required: false
  argument :slug, String, required: false
  argument :include_trashed, Boolean, required: false

  type Mobile::Graph::Types::Discussion::ThreadType, null: true

  def resolve(id: nil, slug: nil, include_trashed: false)
    scope = Discussion::Thread.friendly
    scope = scope.not_trashed unless include_trashed

    thread = scope.find(id || slug)

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
