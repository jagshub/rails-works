# frozen_string_literal: true

# NOTE(rstankov): Makes a model votable.
#
# Required database columns for the model:
#
#   add_column :collections, :votes_count, :integer, null: false, default: 0
#   add_column :collections, :credible_votes_count, :integer, null: false, default: 0
#
# Optionally add index for the model:
#
#   add_index :collections, :credible_votes_count
#
# Also add your model class name in Vote::SUBJECT_TYPES.
#
# If model is exposed in GraphQL it must implement `Graph::Types::VotableInterfaceType`

module Votable
  extend ActiveSupport::Concern

  included do
    include ExplicitCounterCache

    has_many :votes, as: :subject, dependent: :destroy
    has_many :voters, foreign_key: 'user_id', through: :votes, source: :user

    scope :by_credible_votes_count, -> { order(arel_table[:credible_votes_count].desc) }

    explicit_counter_cache :votes_count, -> { votes }
    explicit_counter_cache :credible_votes_count, -> { votes.credible }

    def refresh_all_vote_counts
      refresh_votes_count
      refresh_credible_votes_count
    end
  end

  def self.add_many_votes(user_class, class_names:)
    class_names.each do |class_name|
      name = get_model_name(class_name).param_key

      user_class.has_many :"#{ name }_votes", -> { where(subject_type: class_name) }, class_name: 'Vote'
      user_class.has_many :"voted_#{ name.pluralize }", -> { visible }, source: :subject, source_type: class_name, through: :"#{ name }_votes"
    end
  end

  def self.scopes(vote_class, class_names:)
    class_names.each do |class_name|
      vote_class.scope :"for_#{ get_model_name(class_name).plural }", -> { vote_class.where(subject_type: class_name) }
    end
  end

  def self.get_model_name(class_name)
    class_name.safe_constantize.model_name
  end
end
