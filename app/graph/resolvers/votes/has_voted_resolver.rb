# frozen_string_literal: true

module Graph::Resolvers
  class Votes::HasVotedResolver < Graph::Resolvers::Base
    type Boolean, null: false

    def resolve
      return false if current_user.blank?

      Graph::Common::BatchLoaders::HasVoted.for(current_user).load(object)
    end
  end
end
