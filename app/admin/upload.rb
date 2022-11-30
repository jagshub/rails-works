# frozen_string_literal: true

ActiveAdmin.register_page 'Upload' do
  menu false

  page_action :create, method: :post do
    file = MediaUpload.store(params[:file])

    render json: {
      uuid: file.image_uuid,
      width: file.original_width,
      height: file.original_height,
      preview_url: Image.call(file.image_uuid),
    }
  end
end
