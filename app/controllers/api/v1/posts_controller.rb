# frozen_string_literal: true

class API::V1::PostsController < API::V1::BaseController
  before_action -> { doorkeeper_authorize! :public }, only: :all

  def index
    topic = find_topic(params[:category_slug] || params.fetch(:search, {})[:category])

    return handle_record_not_found if topic.blank?

    scope = topic == :all ? Post : Post.in_topic(topic)

    @posts = Posts::Ranking.for_day(parse_day, scope: scope)

    # Note(LukasFittl): We have to preload explicitly since we want to avoid N+1 queries
    #  when running for different categories, with different kinds of ranking
    ActiveRecord::Associations::Preloader.new.preload(@posts, Post.preload_attributes_for_api)

    return unless stale?(@posts)

    render json: serialize_collection(API::V1::BasicPostSerializer, @posts, root: :posts)
  end

  def show
    @post = Post.visible.with_preloads_for_api.includes(:comments, :votes, :user).friendly.find(params[:id])

    return unless stale?(@post)

    render json: serialize_resource(API::V1::PostSerializer, @post, root: :post)
  end

  def all
    @posts = API::V1::PostsSearch.results filters: search_params, paging: filter_params

    return unless stale?(@posts)

    render json: serialize_collection(API::V1::BasicPostSerializer, @posts, root: :posts)
  end

  private

  def find_topic(slug)
    return :all if !slug || slug == 'all'

    Topic.find_by slug: slug
  end

  def search_params
    super.merge(params.permit(:user_id, :maker_id))
  end

  def parse_day
    if params[:days_ago].present?
      Time.zone.now.to_date - params[:days_ago].to_i
    elsif params[:day].present?
      time = parse_time(params[:day]) || Time.zone.now
      time.to_date
    else
      Time.zone.now.to_date
    end
  end

  def parse_time(time)
    Time.zone.parse(time)
  rescue ArgumentError
    nil
  end
end
