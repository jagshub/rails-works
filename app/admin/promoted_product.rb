# frozen_string_literal: true

ActiveAdmin.register PromotedProduct do
  # NOTE(DZ): PromotedProduct is deprecated. Use `AdsBudget` instead
  # Deprecation date 2020-01-04
  actions :index, :show

  csv do
    column('Post Name') { |promoted_product| promoted_product.post.name }
    column('Url') { |promoted_product| post_url(promoted_product.post) }
    column :link_visits
    column :link_unique_visits
    column :close_count
    column :promoted_at
  end

  permitted_params = %i(promoted_at
                        post_id
                        deal
                        promoted_product_campaign_id
                        name
                        tagline
                        cta_text
                        thumbnail
                        url
                        home_utms
                        open_as_post_page
                        newsletter_id
                        newsletter_utms
                        newsletter_title
                        newsletter_description
                        newsletter_link
                        newsletter_image_uuid
                        promoted_type
                        start_date
                        end_date
                        topic_bundle
                        analytics_test)

  permit_params(*permitted_params)

  config.batch_actions = false
  config.per_page = 40
  config.paginate = true

  menu label: 'Promoted Products', parent: 'Revenue'

  filter :promoted_at
  filter :post_id
  filter :post_slug, as: :string
  filter :promoted_type, as: :select, collection: PromotedProduct.promoted_types

  controller do
    before_action do
      @page_title = 'Promoted Products (DEPRECATED)'
    end

    def scoped_collection
      PromotedProduct.includes(:post)
    end
  end

  index do
    column :id do |resource|
      link_to resource.id, admin_promoted_product_path(resource)
    end
    column :promoted_type do |resource|
      resource.standard? ? 'standard' : 'related_post'
    end
    column :post do |resource|
      resource.post_id.present? ? resource.post : resource.name
    end
    column :campaign do |resource|
      resource.campaign&.name
    end
    column :static do |resource|
      resource.post_id.blank?
    end
    column :topic_targeted do |resource|
      resource.topic_bundle.present?
    end
    column :link_visits
    column :link_unique_visits
    column :close_count
    column :promoted_at
    column :trashed_at
  end

  show do
    default_main_content

    attributes_table do
      row :post_id
    end
  end

  form do |f|
    f.inputs 'Promotion' do
      f.semantic_errors(*f.object.errors.attribute_names)
      f.input :promoted_type, selected: f.object.promoted_type || 'standard'
      f.input :post_id, include_blank: true
      f.input :deal, hint: 'Example: 10% OFF'
      f.input :promoted_product_campaign_id
      f.input :promoted_at, as: :datetime_picker, include_blank: false
      f.input :start_date, as: :datetime_picker
      f.input :end_date, as: :datetime_picker
      f.input :name
      f.input :tagline
      f.input :cta_text
      f.input :thumbnail, as: :file, hint: image_preview_hint(f.object.thumbnail_url, 'Product Thumbnail')
      f.input :url, hint: 'This will override both newsletter and PH links. Use if client needs custom external url.'
      f.input :open_as_post_page, as: :boolean, hint: 'Check this if you want the home page item to open product page'
      f.input :home_utms, input_html: { rows: 3 }, hint: 'For multiple UTM use "&" in between. Eg: utm_medium=ph_promo&utm_campaign=ph_promoted_home'
      f.input :newsletter_utms, input_html: { rows: 3 }, hint: 'For multiple UTM use "&"" in between. Eg: utm_medium=ph_promo&utm_campaign=ph_promoted_newsletter'
      f.input :analytics_test, as: :boolean, hint: 'Activating this will add an utm_content param. Talk to @zyqxd first'
    end
    f.inputs 'Newsletter' do
      f.input :newsletter_id
      f.input :newsletter_title
      f.input :newsletter_description, input_html: { rows: 5 }
      f.input :newsletter_link, input_html: { rows: 1 }
      div render('newsletter_image', promoted: f.object)
    end
    f.actions
  end
end
