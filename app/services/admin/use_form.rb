# frozen_string_literal: true

module Admin::UseForm
  extend self

  def call(active_admin, form_class)
    active_admin.instance_eval do
      permit_params form_class.attribute_names

      controller do
        define_method(:the_form_class) { form_class }

        def new
          @resource = the_form_class.new
        end

        def create
          @resource = the_form_class.new
          @resource.update params.permit![resource_class.name.underscore.tr('/', '_').to_sym]

          respond_with @resource, location: collection_path
        end

        def edit
          @resource = the_form_class.new find_resource
        end

        def update
          @resource = the_form_class.new find_resource
          success = @resource.update params.permit![resource_class.name.underscore.tr('/', '_').to_sym]

          if success
            respond_with @resource, location: collection_path
          else
            message = "Validation failed: #{ @resource.errors.full_messages.join(', ') }"
            respond_with @resource, alert: message
          end
        end
      end
    end
  end

  def extend_form(form, attribute_name)
    form.instance_eval do
      delegate :id, :persisted?, to: attribute_name

      alias_method :to_model, attribute_name

      def to_param
        id
      end
    end
  end
end
