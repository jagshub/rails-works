# frozen_string_literal: true

module ActiveAdmin::BestInPlaceHelper
  def bip_tag(resource, field, reload:, **kargs)
    # NOTE(DZ): reload data attribute is used in javascripts/admin.js:10
    data = (kargs[:data] || {}).merge(reload: reload)
    classname = "bip-editable #{ kargs[:class] }"

    best_in_place resource, field, **kargs, data: data, class: classname
  end

  def bip_status_tag(resource, field, **kargs)
    classname = "status_tag #{ resource.public_send(field) ? 'yes' : 'no' }"

    bip_tag resource, field, class: classname, as: :checkbox, **kargs
  end
end
