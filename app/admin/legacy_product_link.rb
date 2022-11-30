# frozen_string_literal: true

ActiveAdmin.register LegacyProductLink do
  menu label: '[Legacy] Product links', parent: 'Posts'

  permit_params :post_id, :url, :short_code, :store

  filter :post_id
  filter :url
  filter :short_code
  filter :store

  action_item :search_by_regex, only: :index do
    link_to 'Search by regex', action: :search_by_regex
  end

  controller do
    def scoped_collection
      LegacyProductLink.includes(:post)
    end
  end

  index pagination_total: false do
    column :product_id
    column 'Post' do |link|
      post = link.post
      link_to post.name, admin_post_path(post) if post.present?
    end
    column :url
    column :short_code
    column 'Store', &:store

    actions
  end

  form do |f|
    f.inputs 'Product Links' do
      f.semantic_errors(*f.object.errors.attribute_names)
      f.input :post_id, as: :reference, label: 'Post ID'
      f.input :url, as: :string
      f.input :store, as: :select, collection: LegacyProductLink.stores.keys.to_a
    end
    f.actions
  end

  collection_action :search_by_regex, method: %i(get) do
    @regex = params[:regex].present? && Regexp.new(params[:regex])
    @links = nil

    if params[:query].present?
      @links = LegacyProductLink.where('url LIKE ?', LikeMatch.simple(params[:query].strip.downcase)).page(params[:page]).per(100)
    end

    render 'admin/legacy_product_link/search_by_regex'
  end
end
