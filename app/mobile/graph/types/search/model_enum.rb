# frozen_string_literal: true

class Mobile::Graph::Types::Search::ModelEnum < Mobile::Graph::Types::BaseEnum
  graphql_name 'SearchModel'

  def self.searchable_models_enumify(model)
    case model.name
    when 'Anthologies::Story'
      'AnthologiesStory'
    when 'Discussion::Thread'
      'DiscussionThread'
    when 'Post', 'Product', 'UpcomingPage', 'User', 'Topic', 'Collection'
      model.name
    else
      raise "Unknown search model #{ model.name }"
    end
  end

  Search::Searchable.models.each do |model|
    value searchable_models_enumify(model), model.name
  end
end
