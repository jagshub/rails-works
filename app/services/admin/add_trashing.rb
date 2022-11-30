# frozen_string_literal: true

module Admin::AddTrashing
  extend self

  def call(active_admin)
    active_admin.instance_eval do
      scope(:trashed, &:trashed)

      member_action :trash, method: :put do
        resource.trash
        redirect_to resource_path, notice: 'Record was trashed!'
      end

      member_action :restore, method: :put do
        resource.restore
        redirect_to resource_path, notice: 'Record has been restored!'
      end

      action_item 'Trash', only: %i(edit show) do
        if resource.trashed?
          link_to 'Restore', [:restore, :admin, resource], method: :put
        else
          link_to 'Trash (Can be restored)', [:trash, :admin, resource], method: :put
        end
      end
    end
  end
end
