# frozen_string_literal: true

module API::V2Internal::Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    null false

    field :errors, [API::V2Internal::Types::ErrorType], null: false

    def perform
      raise NotImplementedError
    end

    attr_reader :inputs, :ctx, :current_user, :node, :obj

    def resolve(inputs = {})
      @obj = object
      @inputs = ActiveSupport::HashWithIndifferentAccess.new(inputs.to_h)
      @ctx = context
      @current_user = context[:current_user]

      @node = self.class.node_fetch.call @inputs, current_user: current_user

      result = perform

      if result.nil?
        success
      elsif result.is_a?(Hash)
        result
      elsif result.respond_to?(:errors) && result.errors.any?
        errors_from_record result
      elsif result.respond_to?(:node)
        success result.node
      else
        success result
      end
    rescue ActiveRecord::RecordInvalid => e
      errors_from_record(e.record)
    rescue ActiveRecord::RecordNotFound
      error :base, :record_not_found
    rescue MiniForm::InvalidForm => e
      { errors: Error.from_record(e) }
    rescue KittyPolicy::AccessDenied
      error :base, :access_denied
    end

    def request_info
      @request_info ||= RequestInfo.new(ctx[:request]).to_hash
    end

    def success(node = nil)
      if node.present?
        { node: node, errors: [] }
      else
        { errors: [] }
      end
    end

    def error(field, message)
      { errors: [Error.new(field, message)] }
    end

    def errors_from_record(record)
      { errors: Error.from_record(record) }
    end

    class Error
      class << self
        def from_record(record)
          record.errors.group_by_attribute.reduce([]) do |result_arr, (attribute, error_arr)|
            result_arr << Error.new(attribute, error_arr.map(&:message))
          end
        end
      end

      attr_reader :field, :messages

      def initialize(field, messages)
        @field = field
        @messages = Array(messages)
      end

      def ==(other)
        # NOTE(emilov): the array comparison would fail if both are sorted differently.
        # Use sets to ensure all error messages are the same.
        field == other.field && messages.to_set == other.messages.to_set
      end
    end

    class NodeFetch
      attr_writer :node_name, :node_type, :authorize_rule, :authorize_fetch_record

      def call(inputs, current_user:)
        return unless @node_name

        node = find_record(inputs)
        authorize! node, current_user if @authorize_rule.present?
        node
      end

      private

      def authorize!(node, current_user)
        record = @authorize_fetch_record ? @authorize_fetch_record.call(node) : node
        ApplicationPolicy.authorize! current_user, @authorize_rule, record
      end

      def find_record(inputs)
        return @node_type.find(inputs[@node_name]) if @node_type.present?

        subject = inputs[@node_name]
        record_class = subject[:type].safe_constantize
        record = record_class&.find_by(id: subject[:id])

        raise ActiveRecord::RecordNotFound if record.blank?

        record
      end
    end

    class << self
      def returns(type)
        field :node, type, null: true
      end

      def authorize(authorize_rule, &block)
        node_fetch.authorize_rule = authorize_rule
        node_fetch.authorize_fetch_record = block
      end

      def node(node_name, type: nil)
        node_name = "#{ node_name }_id" unless type.nil?

        node_fetch.node_name = node_name
        node_fetch.node_type = type

        argument node_name, type ? GraphQL::Types::ID : API::V2Internal::Types::SubjectInputType, required: true, camelize: false
      end

      def node_fetch
        @node_fetch ||= NodeFetch.new
      end
    end
  end
end
