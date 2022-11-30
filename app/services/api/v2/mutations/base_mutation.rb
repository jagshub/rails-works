# frozen_string_literal: true

module API::V2::Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    null false

    field :errors, [API::V2::Types::ErrorType], null: false

    delegate :current_user, :current_application, :write_scope_allowed?, :request_info, to: :context

    def perform(_inputs)
      raise NotImplementedError
    end

    def resolve(inputs = {})
      return error :base, :access_denied unless current_application && current_user
      return error :base, :access_denied if self.class.block_spam_users && (current_user.potential_spammer? || current_user.spammer?)
      return error :base, 'Your application does not have write access enabled. Please contact hello@producthunt.com with your API Key.' unless write_scope_allowed?

      inputs = FindRecords.call(inputs, self.class.records, current_user) if self.class.records.present?

      result = method(:perform).arity.zero? ? perform : perform(inputs)

      if result.respond_to?(:errors) && result.errors.any?
        { errors: Error.from_record(result) }
      elsif result.is_a?(Hash)
        if result[:node].present? && result[:node].respond_to?(:errors) && result[:node].errors.any?
          { errors: Error.from_record(result[:node]) }
        else
          track_mutation
          result[:errors] ||= []
          result
        end
      else
        track_mutation
        success result
      end
    rescue ActiveRecord::RecordInvalid => e
      { errors: Error.from_record(e.record) }
    rescue ActiveRecord::RecordNotFound
      error :base, :record_not_found
    rescue KittyPolicy::AccessDenied
      error :base, :access_denied
    end

    def error(field, message)
      { errors: [Error.new(field, message)] }
    end

    def success(node = nil)
      if node.present?
        { node: node, errors: [] }
      else
        { errors: [] }
      end
    end

    def track_mutation
      External::SegmentApi.track(
        event: 'mutation',
        user_id: current_user.id,
        properties: {
          name: self.class.name.split('::').last,
          application_id: current_application.id,
          source: 'api',
        },
      )
    end

    class << self
      # DSL
      def returns(type)
        field :node, type, null: true
      end

      def argument_record(name, klass, required: true, authorize: [], description: '', type_description: '')
        authorize = authorize.is_a?(Array) ? authorize : [authorize]

        @records ||= {}
        @records[name] = [klass, required, authorize]

        argument "#{ name }_id", GraphQL::Types::ID, description, required: required
        argument "#{ name }_type", GraphQL::Types::ID, type_description, required: required if klass.is_a?(Array)
      end

      def spam_users_not_allowed
        @block_spam_users = true
      end

      # :api: private
      attr_reader :records, :block_spam_users
    end

    module FindRecords
      extend self

      def call(inputs, records, current_user)
        records.reduce(inputs.dup) do |acc, (name, (klass, required, authorize_rule))|
          id_key = "#{ name }_id".to_sym

          # NOTE(dhruvparmar372): Incase argument_record is explicitly passed as 'null'
          # do not ignore it as it might be needed to unset association in the mutation
          # for e.g project_id in goal_update can be `null` to remove project for a goal
          explicit_nil_record = acc.key?(id_key) && acc[id_key].nil?
          id = acc.delete(id_key)

          if required || id.present?
            scope = if klass.is_a?(Array)
                      class_name = acc.delete("#{ name }_type".to_sym)
                      klass.find { |c| c.name == class_name }
                    else
                      klass
                    end
            acc[name] = scope.find(id)
            authorize_rule.each { |rule| API::V2::Policy.authorize! current_user, rule, acc[name] }
          elsif explicit_nil_record
            acc[name] = nil
          end
          acc
        end
      end
    end

    class Error
      class << self
        # NOTE(emilov): in the APIs we seem to just use message, singular
        # as opposed to a messages array like we do in base_migration (whis is the correct way).
        # Keeping as is for now to preserve compatibility but this needs looking at.
        def from_record(record)
          record.errors.map { |err| Error.new(err.attribute, err.message) }
        end
      end

      attr_reader :field, :message

      def initialize(field, message)
        @field = field.to_s.camelcase(:lower)
        @message = message
      end
    end
  end
end
