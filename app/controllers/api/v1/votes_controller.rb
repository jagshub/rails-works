# frozen_string_literal: true

class API::V1::VotesController < API::V1::BaseController
  def index
    base = context.scope.preload(context.preloads)
    votes = API::V1::VotesSearch.results scope: base, filters: search_params, paging: filter_params

    return unless stale? votes

    render json: serialize_collection(context.serializer, votes, root: :votes)
  end

  def create
    vote = Voting.create(subject: context.resource, user: context.user, source: :api, request_info: request_info.merge(oauth_application_id: current_application.id))
    if vote.present?
      render json: serialize_resource(context.serializer, vote, root: :vote), status: :created
    else
      handle_error_validation(Vote.new)
    end
  end

  def destroy
    vote = Voting.destroy(subject: context.resource, user: context.user)
    if vote.present?
      render json: serialize_resource(context.serializer, vote, root: :vote), status: :ok
    else
      handle_record_not_found
    end
  end

  private

  # Note (LukasFittl): This is called by cancancan, don't remove it.
  def parent_resource
    context.resource
  end

  def context
    @context ||= if params[:post_id].present?
                   ContextPost.new Post.find(params[:post_id]), current_user
                 elsif params[:user_id].present?
                   ContextUser.new User.find(params[:user_id]), current_user
                 elsif params[:comment_id].present?
                   ContextComment.new Comment.find(params[:comment_id]), current_user
                 end
  end

  class Context
    attr_reader :resource, :user

    def initialize(resource, user)
      @resource = resource
      @user     = user
    end

    %i(scope preloads serializer params).each do |method_name|
      define_method(method_name) do
        raise NotImplementedError
      end
    end
  end

  class ContextPost < Context
    def scope
      Voting.votes(subject: @resource, as_seen_by: @user)
    end

    def preloads
      { user: User.preload_attributes }
    end

    def serializer
      API::V1::VoteWithUserSerializer
    end

    def params
      { post: @resource, user: @user }
    end
  end

  class ContextComment < Context
    def scope
      Voting.votes(subject: @resource, as_seen_by: @user)
    end

    def preloads
      { user: User.preload_attributes }
    end

    def serializer
      API::V1::CommentVoteWithUserSerializer
    end

    def params
      { comment: @resource, user: @user }
    end
  end

  class ContextUser < Context
    def scope
      Voting.votes_by(@resource, type: :post, as_seen_by: @user)
    end

    def preloads
      { subject: Post.preload_attributes_for_api }
    end

    def serializer
      API::V1::VoteWithPostSerializer
    end

    def params
      raise 'Either post or comment are required, not users'
    end
  end
end
