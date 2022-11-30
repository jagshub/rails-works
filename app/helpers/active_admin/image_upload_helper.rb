# frozen_string_literal: true

module ActiveAdmin::ImageUploadHelper
  def image_preview_hint(image, message, opts = {})
    hint_text = ''

    if image.present?
      image += opts[:image_url_suffix] if opts[:image_url_suffix].present?
      hint_text += "#{ image_tag(image, style: 'max-width: 300px') }<br>"
    end

    hint_text += message
    hint_text.html_safe
  end

  def inline_file_upload(name: nil, value: nil, id: nil)
    preview_content = value.blank? ? '' : link_to(image_tag(Image.call(value)), Image.call(value), target: '_blank', rel: 'noopener')
    preview = content_tag :div, preview_content, data: { 'upload-preview' => true }, class: 'admin--uploader--preview'
    clear = link_to 'clear', '#', data: { 'upload-clear' => true }, class: 'admin--uploader-clear', style: value.blank? ? 'display: none' : nil
    hint = content_tag :div, "Upload image: #{ clear }".html_safe, class: 'admin--uploader--hint'
    input = file_field_tag '_file', accept: 'image/*', id: id
    hidden_input = name ? hidden_field_tag(name, value) : ''.html_safe

    content_tag :div, preview + hint + input + hidden_input, data: { 'upload' => true }, class: 'admin--uploader'
  end
end
