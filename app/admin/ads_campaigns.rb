# frozen_string_literal: true

ActiveAdmin.register Ads::Campaign, as: 'Campaigns' do
  Admin::UseForm.call self, Ads::Admin::CampaignForm

  menu label: 'Ads -> Campaigns', parent: 'Revenue'

  filter :name

  actions :all, except: :destroy

  includes :post

  member_action :destroy_media do
    resource.media.find(params[:media_id]).destroy

    redirect_back(
      notice: "Campaign Media #{ params[:media_id] } has been destroyed!",
      fallback_location: admin_campaigns_path,
    )
  end

  index do
    id_column
    column :name do |resource|
      resource.post_id.present? ? resource.post : resource.name
    end
    column :budgets_count
    actions defaults: true do |resource|
      span link_to(
        'Budgets',
        admin_budgets_path(q: { campaign_id_eq: resource.id }),
      )
      span link_to 'New budget', new_admin_budget_path(campaign_id: resource.id)
    end
  end

  action_item :new_budget, only: :show do
    link_to 'New budget', new_admin_budget_path(campaign_id: resource.id)
  end

  show do
    default_main_content

    panel 'Budgets' do
      table_for resource.budgets.order(start_time: :desc) do
        column :kind
        column :amount
        column :start_time
        column :end_time
        column :actions do |budget|
          span link_to 'show', admin_budget_path(budget)
          span link_to 'edit', edit_admin_budget_path(budget)
        end
      end
    end

    panel 'Media' do
      table_for resource.media do
        column 'Preview' do |media|
          image_tag media.image_url(width: 130, height: 95)
        end
        column :priority
        column :image_url
        column :created_at

        column :destroy do |media|
          link_to(
            'Delete',
            destroy_media_admin_campaign_path(
              resource,
              media_id: media.id,
            ),
          )
        end
      end
    end

    render 'admin/shared/audits'
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    f.inputs 'Campaign Post (Optional)' do
      f.input :post_id, include_blank: true
    end

    f.inputs 'Campaign Details' do
      li class: 'label' do
        strong 'Note: If post is set, post values will be copied over.'
        strong 'If both campaign post and details are set, then details here
                will replace copied values'
      end

      f.input :name, required: true
      f.input :tagline, required: true
      f.input :thumbnail,
              as: :file,
              required: true,
              hint: image_preview_hint(
                f.object.thumbnail_url,
                'Thumbnail Image. Note: GIF images will only display the first frame
                on desktop web experience until hovered. Gifs will still autoplay on mobile web and app.',
              )
      f.input :url, required: true
    end

    f.inputs 'Campaign Configuration' do
      f.input :cta_text
      f.input :url_params,
              hint: 'For multiple UTM use "&" in between. Eg:
                     utm_medium=ph_promo&utm_campaign=ph_promoted_home'
    end

    panel 'Media' do
      f.has_many :media,
                 heading: false,
                 sortable: :priority,
                 allow_destroy: true do |m|
        m.input :media,
                as: :file,
                hint: image_preview_hint(m.object.image_url, 'Image')

        m.input :image_url,
                label: 'media_url',
                hint: 'use in markdown editor with ![Alt Name](media_url)',
                input_html: { disabled: true }
      end
    end

    f.actions
  end
end
