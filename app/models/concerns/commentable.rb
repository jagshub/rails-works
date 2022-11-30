# frozen_string_literal: true

# NOTE(DZ): Makes a model commentable.
#
# Requires association to :user for now
#   belongs_to :user
#
# Suggested migration:
#   add_column :anthologies_stories, :comments_count, :integer, null: false, default: 0
#
# Also add your model class to these methods:
#   Comments::Commentable#name
#   Routes::CustomPaths::OriginalRoutes#comments_url + comments_path
#
# If model is exposed in GraphQL it must implement `CommentableInterfaceType`
# and you need to add it in Routes::CustomPaths::OriginalRoutes#comment_path

module Commentable
  extend ActiveSupport::Concern

  included do
    include ExplicitCounterCache

    has_many :comments, as: :subject, dependent: :destroy
    has_many :commenters, -> { distinct }, through: :comments, source: :user

    explicit_counter_cache :comments_count, -> { comments.visible }
  end
end
