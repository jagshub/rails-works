# frozen_string_literal: true

class Search::Query::DevProduct < Search::Query::Base
  attr_reader :rank_by, :weight, :decay, :boosts

  def initialize(query, rank_by: 'total', weight: 50, decay: 50, boosts: {})
    @rank_by = rank_by
    @weight = weight
    @decay = decay
    @boosts = boosts
    super(query)
  end

  def base_options
    @base_options ||= {
      models: [Product],
      fields: [
        "name^#{ boosts.fetch('name', 20) }",
        "topics^#{ boosts.fetch('topics', 20) }",
        "body^#{ boosts.fetch('body', 4) }",
        "meta.launches^#{ boosts.fetch('launches', 4) }",
        "related_items^#{ boosts.fetch('related', 1) }",
      ],
    }
  end

  VOTE_TYPE = {
    'average' => 'meta.avg_votes_count',
    'max' => 'meta.max_votes_count',
    'total' => 'meta.total_votes_count',
  }.freeze
  def get_function
    score_weight = weight / 100.0
    vote_weight = (100 - weight) / 100.0

    {
      functions: [{
        script_score: {
          script: {
            params: {
              score_w: score_weight,
              vote_w: vote_weight,
            },
            source: <<-TEXT.squish.squeeze(' '),
              Math.pow(_score, params.score_w) *
              Math.pow(doc['#{ VOTE_TYPE.fetch(rank_by) }'].value, params.vote_w)
            TEXT
          },
        },
      }, {
        gauss: {
          'meta.last_launched_at': {
            offset: '180d',
            scale: '730d',
            # NOTE(DZ): range is (0..1)
            decay: (100 - decay) / 101.0 + 0.001,
          },
        },
      }],
      boost_mode: 'replace',
    }
  end
end
