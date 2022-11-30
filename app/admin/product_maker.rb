# frozen_string_literal: true

ActiveAdmin.register ProductMaker do
  menu false

  permit_params :user_id, :post_id

  form do |f|
    f.inputs do
      f.input :user_id, label: 'User ID'
      f.input :post_id, label: 'Post ID'
    end
    f.buttons
  end
end
