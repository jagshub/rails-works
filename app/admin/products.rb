# frozen_string_literal: true

ActiveAdmin.register Product, as: 'Products' do
  menu label: 'Products'

  config.batch_actions = true

  permit_params(
    :website_url,
    :tagline,
    :description,
    :slug,
    :name,
    :visible,
    :reviewed,
    :twitter_url,
    :facebook_url,
    :instagram_url,
    :angellist_url,
    :github_url,
    :medium_url,
    :logo,
  )

  actions :all, :import_url, :merge, except: :new

  scope :reviewed, default: true
  scope :unreviewed

  action_item :import_url, only: :index do
    link_to 'Import (URL)', action: :import_url
  end

  action_item :merge, only: :index do
    link_to 'Merge two products', action: :merge
  end

  action_item :associate_posts, only: :show do
    link_to 'Associate Posts', action: :associate_posts
  end

  member_action :mark_as_offline do
    ::Products.mark_as_offline(resource)

    redirect_to admin_product_path(resource)
  end

  action_item :mark_as_offline,
              only: %i(show),
              if: proc { resource.live? } do
    link_to 'Mark as offline', action: :mark_as_offline
  end

  member_action :trash do
    resource.trash

    redirect_to admin_product_path(resource)
  end

  action_item :trash,
              only: %i(show),
              if: proc { !resource.trashed? } do
    link_to 'Trash', action: :trash
  end

  member_action :restore do
    resource.restore

    redirect_to admin_product_path(resource)
  end

  action_item :restore,
              only: %i(show),
              if: proc { resource.trashed? } do
    link_to 'Restore', action: :restore
  end

  action_item :mark_as_live,
              only: %i(show),
              if: proc { resource.no_longer_online? } do
    link_to(
      'Mark as live',
      admin_product_path(resource),
      data: {
        confirm: 'To mark the product as live, please set one of its posts as live and we will automatically update the product state',
      },
    )
  end

  filter :id
  filter :slug
  filter :name
  filter :state
  filter :clean_url
  filter :visible
  filter :twitter_url
  filter :facebook_url
  filter :instagram_url
  filter :angellist_url
  filter :github_url
  filter :medium_url
  filter :reviewed_by, label: 'Reviewed by', as: :select, collection: lambda {
    moderator_ids = ModerationLog.where(reference_type: 'Product').select(:moderator_id)
    User.where(id: moderator_ids)
  }

  batch_action :make_visible do |ids|
    Product.where(id: ids).update_all(visible: true)
    redirect_to admin_products_path, notice: 'Selected products are now visible'
  end

  batch_action :hide do |ids|
    Product.where(id: ids).update_all(visible: false)
    redirect_to admin_products_path, notice: 'Selected products are now hidden'
  end

  controller do
    def scoped_collection
      Product.includes(:scrape_results, :moderation_logs)
    end

    def find_resource
      Product.includes(:categories).friendly.find(params[:id])
    end
  end

  index do
    selectable_column

    column :id
    column :name
    column :slug do |product|
      link_to(product.slug, Routes.product_path(product.slug))
    end
    column :website_url do |product|
      link_to(product.website_url, product.website_url, target: '_blank', rel: 'noopener')
    end

    column :visible
    column :state
    column :reviewed_by do |product|
      product.moderation_logs.map(&:moderator)
    end

    column :review_reason do |product|
      product.moderation_logs.map(&:reason)
    end

    actions
  end

  show do
    default_main_content do
      row :id
      row :producthunt_page do |product|
        link_to(product.slug, Routes.product_path(product.slug))
      end
    end

    panel 'Post Associations' do
      associations =
        resource
        .post_associations
        .joins(:post)
        .order(Arel.sql('COALESCE(posts.featured_at, posts.scheduled_at) DESC'))

      paginated_collection(
        associations.page(params[:post_associations_page]).per(15),
        download_links: false,
        param_name: 'post_associations_page',
      ) do
        table_for collection do
          column :id
          column :source
          column :post
          column :post_date do |post_association|
            post_association.post.date
          end
          column :post_hunter do |post_association|
            post_association.post.user
          end
          column :post_makers do |post_association|
            post_association.post.makers
          end
          column :featured do |post_association|
            post_association.post.featured?
          end
          column :actions do |post_association|
            link_to(
              'Delete',
              destroy_post_association_admin_product_path(
                resource,
                post_id: post_association.post_id,
              ),
              method: :delete,
            )
          end
        end
      end
    end

    panel 'Product Associations' do
      associations = resource.product_associations.order('created_at DESC')

      paginated_collection(
        associations.page(params[:product_associations_page]).per(15),
        download_links: false,
        param_name: 'product_associations_page',
      ) do
        table_for collection do
          column :id
          column :source
          column :relationship
          column :associated_product
          column :created_at
          column :updated_at
          column :actions do |post_association|
            link_to(
              'Delete',
              destroy_product_association_admin_product_path(
                resource,
                associated_product_id: post_association.associated_product_id,
              ),
              method: :delete,
            )
          end
        end
      end
    end

    panel 'Categories' do
      table_for resource.category_associations do
        column :name do |category_association|
          link_to(
            category_association.category.name,
            admin_product_category_path(category_association.category),
          )
        end
        column :source
        column :products_count do |category_association|
          category_association.category.products_count
        end
      end
    end

    panel 'Scrape Results' do
      table_for resource.scrape_results.order(created_at: :desc) do
        column 'Scraped at' do |result|
          result.created_at.to_s :long
        end
        column 'Scraper', &:source
        column 'Data' do |result|
          simple_format(
            result.data.map do |key, value|
              "<strong>#{ key }</strong>: #{ value }"
            end.join("\n"),
          )
        end
      end
    end

    render 'admin/shared/audits'
  end

  form do |f|
    f.semantic_errors

    f.inputs 'Details' do
      f.input :visible, label: 'Visible on the site'
      f.input :logo, as: :file, hint: image_preview_hint(f.object.logo_url, "If there's no logo, the thumbnail of the latest launch will be used")
      f.input :name
      f.input :slug
      f.input :website_url
      f.input :tagline, required: true
      f.input :description, as: :text
      f.input :reviewed
      f.input :twitter_url
      f.input :facebook_url
      f.input :instagram_url
      f.input :angellist_url
      f.input :github_url
      f.input :medium_url
    end

    f.actions
  end

  collection_action :import_url, method: %i(post get) do
    @import = Products.admin_import_url_form.new

    if request.get?
      render 'admin/products/import_url'
    else
      @import.update params.require(:import_url).permit(:website_url, :name)

      if @import.errors.blank?
        redirect_to(
          admin_product_path(@import.product),
          notice: 'Product created, scrapers scheduled',
        )
      end
    end
  end

  collection_action :merge, method: %i(post get) do
    if request.get?
      render 'admin/products/merge'
    else
      merge_params = params.require(:merge).permit(:source_id, :target_id)
      source = Product.find(merge_params.fetch(:source_id))
      target = Product.find(merge_params.fetch(:target_id))

      Products::Merge.take_posts(source: source, target: target, user: current_user)

      redirect_to admin_product_path(target), notice: 'Products merged'
    end
  end

  member_action :associate_posts, method: %i(post get) do
    @product_form = Products.admin_associate_posts_form.new(resource)
    @possible_posts = Products.admin_search_possible_posts(resource)

    if request.get?
      render 'admin/products/associate_posts'
    else
      # NOTE(DZ): This is a stupid issue with activeadmin_addon where they
      # generate param key from the form object without any way of overwriting
      post_ids =
        params.require(:associate_posts).require(:suggested_post_ids) +
        params.require(:products_admin_associate_posts_form).require(:posts)
      @product_form.update(post_ids: post_ids)

      # Sync awards from posts
      Products::RefreshActivityEvents.new(resource).call

      redirect_to admin_product_path(resource), notice: 'Saved'
    end
  end

  member_action :destroy_post_association, method: :delete do
    post = Post.find(params['post_id'])
    Products::MovePost.call(post: post, product: nil, source: 'admin', reassociate: true)

    message = "Post '#{ post.slug }' unlinked, moved to product '#{ post.reload.new_product.slug }'"
    redirect_to admin_product_path(resource), notice: message
  rescue ActiveRecord::RecordInvalid => e
    message = "Post '#{ post.slug }' not removed: #{ e.message }"
    redirect_to admin_product_path(resource), alert: message
  end

  member_action :destroy_product_association, method: :delete do
    associated_product = Product.find(params['associated_product_id'])

    Products::ProductAssociation.find_by!(product: resource, associated_product: associated_product).destroy!
    # In case there's an inverse relationship, remove that as well:
    Products::ProductAssociation.find_by(product: associated_product, associated_product: resource)&.destroy!

    message = "Product '#{ associated_product.slug }' unlinked"
    redirect_to admin_product_path(resource), notice: message
  rescue ActiveRecord::RecordInvalid => e
    message = "Product '#{ associated_product.slug }' not removed: #{ e.message }"
    redirect_to admin_product_path(resource), alert: message
  end
end
