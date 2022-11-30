# frozen_string_literal: true

module ActiveAdmin::StatusHelper
  def boolean_field_tag(condition)
    if condition
      raw '<span class="status_tag yes">Yes</span>'
    else
      raw '<span class="status_tag no">No</span>'
    end
  end
end
