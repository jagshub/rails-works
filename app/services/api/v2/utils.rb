# frozen_string_literal: true

module API::V2::Utils
  extend self

  class ComplexityAnalyzer < GraphQL::Analysis::AST::QueryComplexity
    def result
      Rails.logger.info("[GraphQL Query Complexity] #{ max_possible_complexity } ") if Rails.env.development?
    end
  end

  class LogQueryDepth < GraphQL::Analysis::AST::QueryDepth
    def result
      query_depth = super
      Rails.logger.info("[GraphQL Query Depth] #{ query_depth } ")
    end
  end
end
