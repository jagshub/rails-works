# frozen_string_literal: true

module Uploadable
  extend ActiveSupport::Concern

  module ClassMethods
    def uploadable(name)
      uuid_field = "#{ name }_uuid"

      define_method(name) do
        self[uuid_field]
      end

      define_method("#{ name }?") do
        self[uuid_field].present?
      end

      define_method("#{ name }=") do |image|
        return if image.blank?

        upload_image = MediaUpload.store(image)

        self[uuid_field] = upload_image.image_uuid
      end

      define_method("#{ name }_url") do
        Image.call(self[uuid_field])
      end
    end
  end
end
