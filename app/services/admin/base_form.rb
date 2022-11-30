# frozen_string_literal: true

class Admin::BaseForm
  include MiniForm::Model

  delegate :id, :persisted?, :to_param, :new_record?, to: :to_model

  attr_accessor :current_user

  def to_model
    raise NotImplementedError, "call main_model in #{ self.class.name } or include Admin::BaseForm::NoModel"
  end

  class << self
    def model(model_name, nested_attributes: nil, **options)
      super(model_name, **options)

      Array(nested_attributes).each do |(attribute_name, attributes)|
        method_name = "#{ attribute_name }_attributes".to_sym

        delegate attribute_name, to: model_name

        extra_permit_params << { method_name => attributes }

        attributes method_name

        define_method("#{ method_name }=") do |input|
          association = public_send(attribute_name)
          is_has_one = to_model.class.reflect_on_association(attribute_name).macro == :has_one

          if is_has_one
            form_attributes = input.slice(*attributes.map(&:to_s).without('_destroy', 'id'))

            # Note(Rahul): This is to delete current association
            #              and to avoid re-creating association when no changes
            if association.present?
              association.attributes = form_attributes
              return unless association.has_changes_to_save?

              association.destroy!
            end

            record = to_model.public_send("build_#{ attribute_name }")
            record.attributes = form_attributes
          else
            input.values.map(&:stringify_keys).each do |values|
              record = values['id'].present? ? association.find(values['id']) : association.build
              record.attributes = values.slice(*attributes.map(&:to_s).without('_destroy'))
              record.destroy if attributes.include?(:_destroy) && values['_destroy'] == '1'
              association << record if record.persisted?
            end
          end
        end
      end
    end

    def main_model(attribute, main_class)
      alias_method :to_model, attribute

      @main_class = main_class
    end

    def extra_permit_params
      @extra_permit_params ||= []
    end

    def permit_params
      attribute_names + extra_permit_params
    end

    def reflect_on_association(*args)
      raise NotImplementedError, "call main_model in #{ name }" if @main_class.nil?

      @main_class.reflect_on_association(*args)
    end
  end

  module NoModel
    def self.included(base)
      base.extend(ClassMethods)
    end

    def to_model
      OpenStruct.new(id: nil, persited?: false, to_param: nil)
    end

    module ClassMethods
      def reflect_on_association(*_args)
        # noop
      end
    end
  end
end
