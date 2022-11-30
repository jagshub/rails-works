# frozen_string_literal: true

class API::V1::BaseController < ActionController::API
  include RateLimiting
  include ErrorHandling
  include Authorization

  before_action -> { doorkeeper_authorize! :public }, only: %i(index show), unless: :public_endpoint?
  before_action -> { doorkeeper_authorize! :private }, only: %i(create update destroy), unless: :public_endpoint?
  before_action :allowed_to_write?, only: %i(create update destroy), unless: :public_endpoint?

  respond_to :json

  # Note: Adds a suffix to the key used for generating the etag value
  etag { current_user.try(:id) }

  def current_user
    return unless doorkeeper_token.present? && doorkeeper_token.resource_owner_id.present?
    return @current_user if @current_user.present?

    @current_user = User.find(doorkeeper_token.resource_owner_id)

    @current_user
  end

  def request_info
    RequestInfo.new(request).to_hash
  end

  private

  def rate_limit_points_in_request
    1
  end

  def rate_limit_points_quota_per_hour(app)
    app.max_requests_per_hour
  end

  def stale?(obj)
    # Note(andreasklinger): UserFriendAssociation does not contain a updated_at and rails5 does not check upfront but directly fails
    #   If you got time submit a PR to rails/rails that allows passing a selected timestamp column for stale?
    #   https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/metal/conditional_get.rb#L107

    # NOTE(dhruvparmar372): Convert to string before checking since accessing private constants is not recommended
    #   https://github.com/rails/rails/issues/30943
    return true if obj.class.to_s.eql? 'UserFriendAssociation::ActiveRecord_Relation'

    # Note(andreasklinger): We do not support Last-Modified headers to avoid future
    #   problems w/ cloudflare and other proxies.
    # Example case: Cache-Control: public to a "potentially" user depending endpoint like `/posts`
    super(obj, last_modified: nil)
  end

  def serialization_scope
    @serialization_scope ||= {
      current_application: current_application,
      current_user: exclude?('current_user') ? nil : current_user,
      exclude: Array(params[:exclude]),
      include: Array(params[:include]),
    }
  end

  def current_application
    @current_application ||= doorkeeper_token.application
  end

  # Note: We are defaulting all endpoints to require tokens
  #   You can override this per controller
  def public_endpoint?
    false
  end

  def allowed_to_write?
    all_present = doorkeeper_token.present? && doorkeeper_token.application.present?
    # NOTE(Dhruv): Do not allow non-legacy(v2) apps to use write functions in v1 API.
    return if all_present && doorkeeper_token.application.legacy? && doorkeeper_token.application.write_access_allowed?

    raise WritePermissions, 'Your application is not allowed to write data on behalf of the user'
  end

  def exclude?(key)
    return false if params[:exclude].blank?

    Array(params[:exclude]).include? key
  end

  # Note: Default filter strong_params for all controllers
  def filter_params
    default_filter_values.merge(params.permit(:page, :newer, :older, :per_page, :order, :sort_by))
  end

  def default_filter_values
    ActionController::Parameters.new(order: :desc).permit(:order)
  end

  def search_params
    return ActionController::Parameters.new({}) unless params[:search].is_a? ActionController::Parameters

    params.require(:search) || ActionController::Parameters.new({})
  end

  def serialize_resource(serializer_klass, resource, options = {})
    options.reverse_merge! cache: true

    local_scope = serialization_scope
    local_scope.merge!(options[:scope]) if options[:scope]

    if options.delete(:cache)
      ::API::V1::SerializerCache.fetch serializer_klass, resource, local_scope, options do
        Rewired::Renderer.render serializer_klass.resource(resource, local_scope, options)
      end
    else
      Rewired::Renderer.render serializer_klass.resource(resource, local_scope, options)
    end
  end

  def serialize_collection(serializer_klass, collection, options = {})
    options.reverse_merge! cache: true

    local_scope = serialization_scope
    local_scope.merge!(options[:scope]) if options[:scope]

    if options.delete(:cache)
      ::API::V1::SerializerCache.fetch serializer_klass, collection, local_scope, options do
        Rewired::Renderer.render serializer_klass.collection(collection, local_scope, options)
      end
    else
      Rewired::Renderer.render serializer_klass.collection(collection, local_scope, options)
    end
  end
end
