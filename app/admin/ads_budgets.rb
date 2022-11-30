# frozen_string_literal: true

ActiveAdmin.register Ads::Budget, as: 'Budget' do
  Admin::UseForm.call self, Ads::Admin::BudgetForm

  menu label: 'Ads -> Budgets', parent: 'Revenue'

  # NOTE(DZ): New budgets shall only be linked from campaign page so that
  # campaign_id is always available.
  config.remove_action_item :new

  csv do
    column :id
    column :campaign_id
    column :campaign do |resource|
      resource.campaign.name
    end
    column :kind
    column :amount do |resource|
      number_to_currency resource.amount
    end
    column :cpm, sortable: :unit_price do |resource|
      number_to_currency resource.unit_price
    end
    column :impressions_count
    column :clicks_count
    column :channels_count
    column :start_time
    column :end_time
    column 'newsletter-in-feed' do |resource|
      if resource.newsletter.blank?
        'No'
      elsif resource.newsletter.newsletter_id&.present?
        resource.newsletter.newsletter.id
      else
        'Yes'
      end
    end
    column 'newsletter-topline' do |resource|
      resource.newsletter_sponsor.blank? ? 'No' : 'Yes'
    end
  end

  filter :campaign_id_eq, label: 'CAMPAIGN ID'
  filter :kind, as: :select, collection: Ads::Budget.kinds

  actions :all, except: :destroy

  includes :campaign
  includes newsletter: :newsletter
  includes :newsletter_sponsor

  controller do
    def new
      @resource = the_form_class.new
      @resource.campaign_id ||= params[:campaign_id]
    end
  end

  member_action :destroy_media do
    resource.media.find(params[:media_id]).destroy

    redirect_back(
      notice: "Budget Media #{ params[:media_id] } has been destroyed!",
      fallback_location: admin_campaigns_path,
    )
  end

  index do
    id_column
    column :campaign, sortable: 'ads_campaigns.name'
    column :kind
    column :amount do |resource|
      number_to_currency resource.amount
    end
    column :cpm, sortable: :unit_price do |resource|
      number_to_currency resource.unit_price
    end
    column :impressions, :impressions_count
    column :clicks, :clicks_count
    column :channels, :channels_count
    column :start_time
    column :end_time
    column :status do |resource|
      budget_status_tag resource
    end
    column 'Hours' do |resource|
      if resource.active_start_hour == 0 && resource.active_end_hour == 23
        'all day'
      else
        "#{ resource.active_start_hour }:00-#{ resource.active_end_hour }:00"
      end
    end
    column 'Newsletter In-Feed', :newsletter do |resource|
      if resource.newsletter.blank?
        status_tag 'No'
      elsif resource.newsletter.newsletter_id&.present?
        newsletter = resource.newsletter.newsletter
        link_to newsletter.id, admin_newsletter_path(newsletter)
      else
        status_tag 'Auto', class: 'yes'
      end
    end
    column 'Newsletter Topline', :sponsor do |resource|
      resource.newsletter_sponsor.present?
    end
    actions defaults: true do |resource|
      link_to 'Channels', admin_channels_path(q: { budget_id_eq: resource.id })
    end
  end

  show do
    default_main_content

    panel 'Newsletter Channels' do
      attributes_table_for resource do
        row 'In Feed Sponsor' do |resource|
          post_ad = resource.newsletter
          if post_ad.blank?
            status_tag 'No'
          elsif post_ad.newsletter_id&.present?
            newsletter = post_ad.newsletter
            link_to newsletter.id, admin_newsletter_path(newsletter)
          else
            status_tag 'Auto', class: 'yes'
            span ' | '
            link_to(
              'Web preview',
              newsletter_path(Newsletter.sent.last, forcePost: post_ad.id),
              target: '_blank',
              rel: 'noopener',
            )
          end
        end
        row 'Topline Sponsor' do |resource|
          sponsor = resource.newsletter_sponsor
          if sponsor.blank?
            status_tag 'No'
          else
            span link_to(sponsor.id, admin_newsletter_sponsor_path(sponsor))
            span ' | '
            link_to(
              'Web preview',
              newsletter_path(Newsletter.sent.last, forceSponsor: sponsor.id),
              target: '_blank',
              rel: 'noopener',
            )
          end
        end
      end
    end

    panel 'Web Channels' do
      table_for resource.channels.includes(:media).order(active: :desc) do
        column :id
        column :kind
        column :bundle
        column :application
        column :ad_preview do |channel|
          ad = Ads::Ad.new(channel)
          raw(
            {
              id: ad.id,
              name: ad.name,
              kind: ad.kind,
              tagline: ad.tagline,
              post: ad.post&.name,
              cta_text: ad.cta_text,
              url: ad.url,
              media: ad.media.pluck(:uuid),
              thumbnail: ad.thumbnail_uuid,
            }.map do |key, value|
              next if value.blank?

              value +=  '   ' if %i(kind post).include?(key)
              value +=  content_tag :span, 'Source: budget ', class: 'status_tag ' if key == :kind
              value +=  content_tag :span, 'Source: campaign ', class: 'status_tag ' if key == :post
              value = image_tag(Image.call(value, width: 130, height: 95)) if key == :thumbnail
              "<strong>#{ key }</strong>: #{ value }"
            end.join('<br>'),
          )
        end
        column :active do |channel|
          bip_status_tag(
            channel,
            :active,
            reload: true,
            url: bip_admin_channel_path(channel),
          )
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
            destroy_media_admin_budget_path(
              resource,
              media_id: media.id,
            ),
          )
        end
      end
    end

    render 'admin/shared/audits'
  end

  sidebar :stats, only: %i(show edit) do
    attributes_table_for resource do
      row :campaign
      row :status do |resource|
        budget_status_tag resource
      end
      row :fill do |resource|
        resource.cpm? ? number_to_percentage(resource.fill) : status_tag('N/A')
      end
      row :amount
      if resource.daily_cap?
        row :daily_cap_amount
        row :today_impressions_count
        row :today_cap_reached?
      end
      row :hours do |resource|
        if resource.active_start_hour == 0 && resource.active_end_hour == 23
          'all day'
        else
          "#{ resource.active_start_hour }:00-#{ resource.active_end_hour }:00"
        end
      end
      row :impressions, &:impressions_count
      row :clicks, &:clicks_count
      row :unique_clicks do |resource|
        Ads::Interaction
          .unique_clicks
          .left_joins(:channel)
          .where(ads_channels: { budget_id: resource.id })
          .count
      end
      row :closes, &:closes_count
    end
  end

  form do |f|
    f.inputs 'Budget Details' do
      f.input :name
      f.input :tagline
      f.input :thumbnail,
              as: :file,
              hint: image_preview_hint(
                f.object.thumbnail_url,
                'Thumbnail Image. Note: GIF images will only display the first frame
                on desktop web experience until hovered. Gifs will still autoplay on mobile web and app.',
              )
      f.input :url
    end

    text_node javascript_include_tag 'admin_ads_campaign_budgets'

    f.semantic_errors *f.object.errors.attribute_names
    editting = f.object.persisted?

    f.inputs 'Budget Configuration' do
      f.input :cta_text
      f.input :url_params,
              hint: 'For multiple UTM use "&" in between. Eg:
                     utm_medium=ph_promo&utm_campaign=ph_promoted_home'
      f.input :campaign_id,
              required: true,
              as: :hidden,
              input_html: { value: f.object.campaign_id }

      f.input :kind,
              as: :select,
              include_blank: false,
              collection: Ads::Budget.kinds,
              required: true,
              input_html: { disabled: editting }

      f.input :amount, as: :string, required: true

      f.input :daily_cap_amount, as: :number, hint: "The $ amount of ad's budget that can be spent in a day. Use 0 not to have a budget cap."

      f.input :unit_price,
              as: :string,
              label: 'Cost Per (k) Impressions',
              input_html: { disabled: f.object.timed? }

      f.input :impressions, min: 0, input_html: { disabled: f.object.timed? }
      f.input :start_time, as: :datetime_picker
      f.input :number_of_days, as: :number
      f.input :end_time, as: :datetime_picker

      f.input :active_start_hour, as: :number, hint: 'Hide ads before hour has started. Time in PST. Min: 0, Max: 23'
      f.input :active_end_hour, as: :number, hint: 'Hide ads after hour has passed. Time in PST. Min: 0, Max: 23.'
    end

    f.inputs(
      'Newsletter In-Feed Sponsorship',
      for: [:newsletter, f.object.newsletter],
    ) do |n|
      if f.object.can_destroy_newsletter?
        n.input :_destroy,
                as: :boolean,
                label: 'MARK FOR DESTRUCTION'
      end

      if f.object.can_create_newsletter?
        n.input :_create,
                as: :boolean,
                label: 'MARK FOR CREATION'
      end

      n.input :active

      n.input :newsletter_id,
              label: 'Newsletter Id',
              hint: 'If left blank, newsletter will be assigned by weight',
              input_html: { disabled: f.object.newsletter&.newsletter&.sent? }

      n.input :name

      n.input :tagline,
              as: :text,
              input_html: { rows: 3 }

      n.input :thumbnail,
              as: :file,
              hint: image_preview_hint(
                n.object.thumbnail_url,
                'Thumbnail Image. Note: GIF images will only display the ' \
                'first frame on desktop web experience until hovered. Gifs ' \
                'will still autoplay on mobile web and app.',
              )

      n.input :url

      n.input :url_params_str,
              label: 'Url params',
              hint: 'For multiple UTM use "&" in between. Eg:'\
                    'utm_medium=ph_promo&utm_campaign=ph_promoted_home'

      n.input :weight,
              required: true,
              hint: 'Higher will be prioritised first, negative is allowed'
    end

    f.inputs(
      'Newsletter Topline Sponsorship',
      for: [:newsletter_sponsor, f.object.newsletter_sponsor],
    ) do |ns|
      if f.object.can_destroy_newsletter_sponsor?
        ns.input :_destroy,
                 as: :boolean,
                 label: 'MARK FOR DESTRUCTION'
      end

      if f.object.can_create_newsletter_sponsor?
        ns.input :_create,
                 as: :boolean,
                 label: 'MARK FOR CREATION'
      end

      ns.input :active

      ns.input :image,
               as: :file,
               hint: image_preview_hint(
                 ns.object.image_url,
                 'Used in newsletter header ("Brought to you by" line)',
               ),
               required: true

      ns.input :body_image,
               as: :file,
               hint: image_preview_hint(
                 ns.object.body_image_url,
                 'Used in newsletter body where full sponsor appears',
               ),
               required: true

      ns.input :cta, hint: 'Replaces the CTA button text in body'

      ns.input :description_html,
               as: :text,
               required: true,
               hint: 'Main ad body content'

      ns.input :url, required: true
      ns.input :url_params_str

      ns.input :weight,
               required: true,
               hint: 'Higher will be prioritised first, negative is allowed'
    end

    panel 'Web Channels' do
      f.has_many :channels, heading: false do |c|
        if c.object.new_record?
          c.object.url = f.object.campaign.url
          c.object.url_params = f.object.campaign.url_params
        end

        c.input :name
        c.input :tagline
        c.input :thumbnail,
                as: :file,
                hint: image_preview_hint(
                  c.object.thumbnail_url,
                  'Thumbnail Image. Note: GIF images will only display the first frame
              on desktop web experience until hovered. Gifs will still autoplay on mobile web and app.',
                )

        c.input :kind,
                as: :select,
                include_blank: false,
                collection: Ads::Channel.kinds,
                required: true,
                hint: 'Feed is home page and topic page, sidebar shows up on
                       posts and alternatives'

        c.input :bundle,
                as: :select,
                include_blank: false,
                collection: Ads::Channel.bundles,
                required: false,
                hint: '`everything` & `other` does not include `homepage` ads'

        c.input :url

        c.input :url_params_str,
                hint: 'For multiple UTM use "&" in between. Eg:
                       utm_medium=ph_promo&utm_campaign=ph_promoted_home'

        c.input :weight, hint: 'Higher is more priortized, can accept negatives'

        c.input :application,
                as: :select,
                include_blank: false,
                collection: Ads::Channel.applications,
                required: true

        c.input :active
      end
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

  action_item :delete, only: :show, if: proc { resource.impressions_count.zero? } do
    link_to(
      'Destroy',
      delete_admin_budget_path(resource),
      method: :post,
      data: {
        confirm: "Are you sure you want to destroy budget #{ resource.id }?",
      },
    )
  end

  # NOTE(DZ): Action name `delete` since `destroy` will create buttons
  member_action :delete, method: :post do
    resource.destroy

    redirect_to collection_path, notice: "Budget #{ resource.id } has been destroyed"
  end
end
