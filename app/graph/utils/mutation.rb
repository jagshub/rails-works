# frozen_string_literal: true

# NOTE(rstankov): Used as base for all muations
#   # all arguments are camelcased -> `SomeArg`
#   argument :some_arg, String, required: true
#
#   # accepts an argument `postId` and use `Post` model to select `post`
#   argument_record :post, Post
#
#   # can check authorization rules for post
#   argument_record :post, Post, authorize: :edit
#
#   # model can have scopes
#   argument_record :post, -> { Post.visible }, authorize: :edit
#
#   # supports polymorphic records
#   # from `subjectId` / `subjectType` selects proper record
#   # if record has `graphql_type` attribute, it is used to determine `subject_type`
#   argument_record :subject, [Post, Comment], authorize: :edit
#
#   # when writing a spec for a polymorphic situation, see above, you need to supply the graphql type. so if you have this:
#   argument_record :thething, [Post, Subscription, Discussion::Thread]
#   # then in the spec you'd use this:
#   execute_mutation(current_user: user, thething_id: thething.id, thething_type: 'DiscussionThread')
#
#   # same as `argument_record` for multiple records
#   # `postIds`
#   argument_records :post, Post, authorize: :vote
#
#   # validates current user is logged in
#   require_current_user
#
#   # validates current user can create post
#   authorize :create, Post
#
#   # all `argument_record` / `argument_records` are passed as inputs
#   # integrated with `Audited` gem
#   def perform(inputs)
#     current_user # access to current user
#     context # access to context
#
#     # return error
#     error :name, :message if some_validation
#
#     # return an object that defines #graphql_result
#     form = SomeForm.new(product)
#     form.update(**inputs)
#     return form
#
#     # return a hash that holds a `:node` key:
#     form = SomeForm.new(product)
#     form.update(**inputs)
#     return { node: form.object, extra_data: "Foo" }
#   end

class Graph::Utils::Mutation < GraphQL::Schema::RelayClassicMutation
  null false

  def perform(_inputs)
    raise NotImplementedError
  end

  def current_user
    context[:current_user]
  end

  def request_info
    context[:request_info]&.to_hash || {}
  end

  def resolve(inputs = {})
    Helper.authorize!(current_user, self.class.authorize_rules) unless self.class.authorize_rules.nil?

    inputs = Helper.find_records(current_user, self.class.record_rules, inputs) unless self.class.record_rules.nil?

    result = Audited.audit_class.as_user(current_user) do
      method(:perform).arity.zero? ? perform : perform(inputs)
    end

    if result.respond_to?(:errors) && result.errors.any?
      { errors: Error.from_record(result) }
    elsif result.is_a?(Hash)
      if result[:node].present? && result[:node].respond_to?(:errors) && result[:node].errors.any?
        { errors: Error.from_record(result[:node]) }
      else
        result[:errors] ||= []
        result
      end
    elsif result.respond_to?(:graphql_result)
      success result.graphql_result
    elsif result.respond_to?(:node)
      raise "The class `#{ result.class.name }` responds to #node, but not to #graphql_result -- you should alias `graphql_result` to whatever `node` is aliased to"
    else
      success result
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "ActiveRecord::RecordInvalid: #{ e.record.errors.full_messages }" if Rails.env.development?

    { errors: Error.from_record(e.record) }
  rescue MiniForm::InvalidForm => e
    Rails.logger.error "MiniForm::InvalidForm: #{ e.errors.full_messages }" if Rails.env.development?

    { errors: Error.from_record(e) }
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error 'ActiveRecord::RecordNotFound' if Rails.env.development?

    error :base, :record_not_found
  rescue KittyPolicy::AccessDenied
    Rails.logger.error 'KittyPolicy::AccessDenied' if Rails.env.development?

    error :base, :access_denied
  end

  def error(field, message)
    { errors: [Error.new(field, message)] }
  end

  def success(node = nil)
    if node.nil?
      { errors: [] }
    else
      { node: node, errors: [] }
    end
  end

  class << self
    def inherited(base)
      super(base)

      base.instance_eval do
        @authorize_rules = nil
        @record_rules = nil
      end
    end

    def returns(type)
      field :node, type, null: true
    end

    def authorize(*authorize_rules)
      @authorize_rules = authorize_rules
    end

    def require_current_user
      authorize
    end

    def argument_record(name, scope, required: true, authorize: nil)
      finder = SingleRecordFinder.new(scope, required, authorize)

      @record_rules ||= {}
      @record_rules[name] = finder

      argument finder.argument(name), GraphQL::Types::ID, required: required
      argument finder.type_argument(name), GraphQL::Types::String, required: required if finder.polymorphic?
    end

    def argument_records(name, scope, required: true, authorize: nil)
      finder = MultipleRecordsFinder.new(scope, required, authorize)

      @record_rules ||= {}
      @record_rules[name] = finder

      argument finder.argument(name), [GraphQL::Types::ID], required: required
    end

    attr_reader :record_rules, :authorize_rules
  end

  class SingleRecordFinder
    attr_reader :scope, :required, :authorize

    def initialize(scope, required, authorize)
      raise "The scope #{ scope }, needs to be callabe, direct record or array of those" unless valid_scope?(scope)

      @scope = scope
      @required = required
      @authorize = authorize
    end

    def call(name, acc, current_user)
      key = argument(name).to_sym
      is_present = acc.key?(key)

      id = acc.delete(key)
      class_name = acc.delete(type_argument(name).to_sym) if polymorphic?

      if !required && is_present && id.nil?
        acc[name] = nil
      elsif required || id.present?
        acc[name] = find(class_name, id)

        ApplicationPolicy.authorize!(current_user, authorize, acc[name]) if authorize
      end
      acc
    end

    def argument(name)
      "#{ name }_id"
    end

    def type_argument(name)
      "#{ name }_type"
    end

    def polymorphic?
      scope.is_a?(Array)
    end

    private

    def find(class_name, id)
      query = query_for(class_name)

      raise ActiveRecord::RecordNotFound if query.nil?

      query = query.not_trashed if query.respond_to?(:not_trashed)
      query.find(id)
    end

    def query_for(class_name)
      case scope
      when Proc then scope.call
      when Class then scope
      when Array
        type = scope.find { |klass| graphql_type(klass) == class_name }
        raise "Couldn't find class name #{ class_name.inspect } in: #{ scope.map { |k| graphql_type(k) } }" unless type

        type
      end
    end

    def graphql_type(klass)
      if klass.respond_to?(:graphql_type)
        klass.graphql_type.graphql_name
      else
        klass.name
      end
    end

    def valid_scope?(scope)
      case scope
      when Class then true
      when Proc then true
      when Array then scope.all? { |k| k.class == Class }
      else false
      end
    end
  end

  class MultipleRecordsFinder
    attr_reader :scope, :required, :authorize

    def initialize(scope, required, authorize)
      raise "The scope #{ scope }, needs to be callabe or direct record" unless valid_scope?(scope)

      @scope = scope
      @required = required
      @authorize = authorize
    end

    def call(name, acc, current_user)
      key = argument(name).to_sym
      is_present = acc.key?(key)

      ids = acc.delete(key)

      if !required && is_present && ids.nil?
        acc[name] = nil
      elsif required || ids.present?
        acc[name] = find_all(ids)

        if authorize
          acc[name].each do |record|
            ApplicationPolicy.authorize!(current_user, authorize, record)
          end
        end
      end

      acc
    end

    def argument(name)
      "#{ name.to_s.singularize }_ids"
    end

    private

    def find_all(ids)
      return [] if ids.blank?

      query = scope.is_a?(Proc) ? scope.call : scope
      query = query.not_trashed if query.respond_to?(:not_trashed)
      query.find(ids)
    end

    def valid_scope?(scope)
      case scope
      when Class then true
      when Proc then true
      else false
      end
    end
  end

  module Helper
    extend self

    def authorize!(current_user, authorize_rules)
      if authorize_rules.blank?
        raise KittyPolicy::AccessDenied if current_user.nil?
      else
        ApplicationPolicy.authorize!(current_user, *authorize_rules)
      end
    end

    def find_records(current_user, record_rules, inputs)
      record_rules.reduce(inputs.dup) do |acc, (name, finder)|
        finder.call(name, acc, current_user)
      end
    end
  end

  class Error
    class << self
      def from_record(record)
        # TODO(emilov): yes, code dup with resolver/mutation.rb, this will refactored
        record.errors.group_by_attribute.reduce([]) do |result_arr, (attribute, error_arr)|
          result_arr << Error.new(attribute, error_arr.map(&:message))
        end
      end
    end

    attr_reader :field, :messages

    def initialize(field, messages)
      @field = field.to_s.camelcase(:lower)
      @messages = Array(messages)
    end

    def ==(other)
      field == other.field && messages.to_set == other.messages.to_set
    end
  end
end
