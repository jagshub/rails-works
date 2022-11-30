# frozen_string_literal: true

class Graph::Resolvers::GoldenKitty::IsVotedResolver < Graph::Resolvers::Base
  type Boolean, null: false

  def resolve
    return false if current_user.blank?

    VotesLoader.for(current_user).load(object.id)
  end

  class VotesLoader < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(ids)
      voted_ids = @user.votes.where(subject_type: ::GoldenKitty::Finalist.name, subject_id: ids).pluck(:subject_id)

      ids.each do |id|
        fulfill id, voted_ids.include?(id)
      end
    end
  end
end
