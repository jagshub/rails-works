# frozen_string_literal: true

module Graph::Mutations
  class SaveUpcomingPageQuestion < BaseMutation
    class InputOptionType < Graph::Types::BaseInputObject
      graphql_name 'InputUpcomingPageOption'

      argument :id, ID, required: false
      argument :title, String, required: false
    end

    class InputRuleType < Graph::Types::BaseInputObject
      graphql_name 'InputUpcomingPageRule'

      argument :id, ID, required: false
      argument :dependent_upcoming_page_option_id, ID, required: false
    end

    argument_record :upcoming_page_survey, UpcomingPageSurvey, required: true, authorize: ApplicationPolicy::MAINTAIN

    argument :id, ID, required: false
    argument :title, String, required: false
    argument :question_type, String, required: false
    argument :position_in_survey, String, required: false
    argument :include_other, Boolean, required: false
    argument :required, Boolean, required: false
    argument :options, [InputOptionType], required: false
    argument :rules, [InputRuleType], required: false

    returns Graph::Types::UpcomingPageQuestionType

    def perform(upcoming_page_survey:, **inputs)
      Save.call upcoming_page_survey, inputs
    end

    class Save
      def self.call(survey, inputs)
        new.save(survey, inputs)
      end

      attr_reader :errors, :graphql_result

      def initialize
        @graphql_result = nil
        @errors = ActiveModel::Errors.new(nil)
      end

      def save(survey, inputs)
        transaction do
          @graphql_result = update_record!(survey.questions, inputs[:id], inputs) do |question, attributes|
            question = apply_attributes(question, attributes)

            if question.valid?
              update_records(question.options, 'options', attributes[:options]) do |option, option_attributes|
                option.title = option_attributes[:title]
              end

              update_records(question.rules, 'rules', attributes[:rules]) do |rule, rule_attributes|
                option = UpcomingPageQuestionOption.find(rule_attributes[:dependent_upcoming_page_option_id])
                rule.dependent_option = option
                rule.dependent_question = option.question
              end
            end
          end
        end

        @graphql_result.refresh_rules if @node.present? && @node.persisted?

        self
      end

      private

      def valid?
        errors.empty?
      end

      def transaction
        ActiveRecord::Base.connection.transaction do
          yield

          raise ActiveRecord::Rollback unless valid?
        end
      end

      def update_record(relationship, id, attributes, prefix = nil)
        record = id && relationship.find_by(id: id)
        record = relationship.new if record.blank?

        yield record, attributes, prefix

        if record.invalid?
          record.errors.each do |e|
            e_attr = prefix ? "#{ prefix }[#{ e.attribute }]" : e.attribute
            errors.add e_attr, e.message
          end
        end

        record
      end

      def update_record!(*args, &block)
        record = update_record(*args, &block)
        return if record.errors.any?

        record.save!
        record
      end

      def update_records(relationship, prefix, input, &block)
        before_ids = relationship.pluck :id

        records = Array(input).each_with_index.map do |attributes, i|
          update_record relationship, attributes[:id], attributes, "#{ prefix }[#{ i }]", &block
        end

        return if errors.any?

        records.each(&:save!)

        to_remove = before_ids - records.map(&:id).compact
        trash_or_destroy relationship.where(id: to_remove) if to_remove.any?
      end

      def trash_or_destroy(records)
        records.each do |record|
          # NOTE(rstankov): We pass options and rules here, rules don't have answers
          if record.respond_to?(:answers) && record.answers.count > 0
            record.trash
          else
            record.destroy!
          end
        end
      end

      def apply_attributes(question, attributes)
        question.title = attributes[:title]
        question.question_type = attributes[:question_type]
        question.position_in_survey = attributes[:position_in_survey].to_i
        question.include_other = ActiveModel::Type::Boolean.new.cast(attributes[:include_other]) || false
        question.required = ActiveModel::Type::Boolean.new.cast(attributes[:required]) || false
        question
      end
    end
  end
end
