# frozen_string_literal: true

class Search::Query::Collection < Search::Query::Base
  def initialize(query, &block)
    super(query, models: [Collection], &block)
  end

  def base_options
    @base_options ||= {
      models: [Collection],
      fields: [
        'name^50',
        'body^30',
        'meta.products^15',
        'user^5',
      ],
    }
  end

  def get_function
    {
      functions: [{
        gauss: {
          'meta.updated_at': {
            offset: '1d',
            scale: '30d',
            decay: 0.3,
          },
        },
      }],
    }
  end
end
