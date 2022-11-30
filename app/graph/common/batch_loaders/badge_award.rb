# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class BadgeAward < GraphQL::Batch::Loader
    def perform(identifiers)
      awards = ::Badges::Award.where(identifier: identifiers.uniq).to_a

      identifiers.each do |id|
        fulfill(id, awards.find { |award| award.identifier == id })
      end
    end
  end
end
