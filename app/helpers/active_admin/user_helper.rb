# frozen_string_literal: true

module ActiveAdmin::UserHelper
  def formatted_user_name(user)
    format_attribute_for_trashed(user, 'name')
  end

  def formatted_user_role(user)
    format_attribute_for_trashed(user, 'role')
  end

  private

  def format_attribute_for_trashed(user, attribute)
    value = user.send(attribute)
    if user.trashed?
      format('<s>%s</s> deleted', value).html_safe
    else
      value
    end
  end
end
