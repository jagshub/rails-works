# frozen_string_literal: true

ActiveAdmin.register Newsletter do
  permitted_params = [
    :subject,
    :kind,
    :title,
    :date,
    :preview_token,
    :social_image,
    :anthologies_story_id,
    :skip_sponsor,
    :sponsor_title,
    posts: %i(id makers name tagline),
    sections: %i(layout title url content image_uuid subtitle position cta),
    sponsor_attributes: %i(id image_uuid link cta description_html body_image_uuid _destroy),
  ]

  permit_params(*permitted_params)

  config.batch_actions = false
  config.clear_action_items!

  filter :subject
  filter :kind
  filter :status
  filter :date

  controller do
    def scoped_collection
      Newsletter.includes(:experiment)
    end

    def new
      @newsletter = Newsletter.new date: Time.zone.yesterday
    end

    def create
      @newsletter = Newsletter.new permitted_params[:newsletter]
      @newsletter.set_preview_token
      @newsletter.sections = Newsletter::Section.default_sections
      @newsletter.save

      respond_with @newsletter, location: @newsletter.id ? edit_admin_newsletter_path(@newsletter) : admin_newsletters_path
    end

    def edit
      @newsletter = Newsletter.find params[:id]
    end

    def update
      @newsletter = Newsletter.find params[:id]

      @newsletter.update permitted_params[:newsletter]

      respond_with @newsletter, location: admin_newsletters_path
    end
  end

  action_item :create, only: :index do
    link_to 'New Newsletter', new_admin_newsletter_path
  end

  action_item :view_in_site, only: :show do
    link_to 'View in Site', newsletter_path(newsletter), target: '_blank', rel: 'noopener' if newsletter.sent?
  end

  action_item :edit, only: :show do
    link_to 'Edit Newsletter', edit_admin_newsletter_path(newsletter)
  end

  action_item :send, only: :show do
    link_to 'Send Newsletter', confirm_sent_admin_newsletter_path(newsletter), data: { confirm: newsletter.promoted_product.present? ? 'A Promoted Post has been added' : 'Are you sure this newsletter has no Promoted Post?' } if newsletter.sendable?
  end

  action_item :test, only: :show do
    link_to 'Test Newsletter', test_admin_newsletter_path(newsletter)
  end

  action_item :destroy, only: :show do
    link_to 'Delete Newsletter', admin_newsletter_path(newsletter), data: { method: :delete, confirm: 'Are you sure you want to delete this?' } if newsletter.draft?
  end

  member_action :confirm_sent, method: :get do
  end

  member_action :resend, method: :get do
    newsletter = Newsletter.find(params[:id])

    Notifications.notify_about object: newsletter, kind: 'newsletter', long_running: true

    redirect_to admin_newsletters_path, notice: "Newsletter with subject #{ newsletter.subject } and id #{ newsletter.id } has been sent again!"
  end

  member_action :sent, method: :patch do
    response = if Newsletter::Send.call(resource)
                 { notice: 'Newsletter schedule for sending.' }
               else
                 { alert: resource.sent? ? 'Newsletter already sent' : 'Newsletter could not be sent' }
               end

    redirect_to admin_newsletters_path, response
  end

  member_action :test, method: :get do
  end

  member_action :test_send, method: :post do
    if Newsletter::Email.deliver_test(resource, params[:user][:email])
      redirect_to admin_newsletters_path, notice: 'Test email send succesfully.'
    else
      redirect_to test_admin_newsletter_path(resource), alert: 'Invalid email.'
    end
  end

  collection_action :preview_section, method: %i(get post patch) do
    newsletter = params[:id].blank? ? Newsletter.new : Newsletter.find(params[:id])
    newsletter.attributes = params.require(:newsletter).permit(permitted_params) if params[:newsletter].present?

    preview = Newsletter::Email.build_for_admin_preview newsletter, preview_as: current_user

    render html: params[:text] ? "<pre>#{ preview.text } </pre>".html_safe : preview.html.html_safe, layout: false
  end

  index download_links: false, pagination_total: true do
    id_column
    column :subject do |newsletter|
      link_to newsletter.subject, admin_newsletter_path(newsletter)
    end
    column :status
    column :kind
    column :date
    column :skip_sponsor
    column :sponsor_title
    column 'A/B Testing' do |newsletter|
      newsletter.experiment.present?
    end
    actions defaults: false do |newsletter|
      [
        link_to('View', admin_newsletter_path(newsletter)),
        newsletter.draft? ? link_to('Edit', edit_admin_newsletter_path(newsletter)) : nil,
        newsletter.sendable? ? link_to('Test', test_admin_newsletter_path(newsletter)) : nil,
        newsletter.experiment.present? ? link_to('Experiment', admin_newsletter_experiment_path(newsletter.experiment)) : nil,
        newsletter.sendable? ? link_to('Send', confirm_sent_admin_newsletter_path(newsletter)) : nil,
        newsletter.sent? ? link_to('View in site', newsletter_path(newsletter), target: '_blank', rel: 'noopener') : nil,
        link_to('View Report', admin_newsletter_report_path(id: newsletter.id)),
        link_to('View Counter Stats', admin_newsletter_counter_stats_path(id: newsletter.id)),
        newsletter.sent? ? link_to('Resent', resend_admin_newsletter_path(newsletter), confirm: 'Are you sure you want to resend this newsletter?') : nil,
      ].compact.join(' ').html_safe
    end
  end

  show do
    attributes_table do
      row :subject
      row :status
      row :kind
      row :preview_url do
        newsletter_url(newsletter, preview: newsletter.preview_token)
      end
      row :date
      row :skip_sponsor
      row :sponsor_title
    end

    panel "HTML preview, without social data - #{ link_to 'link', preview_section_admin_newsletters_path(id: newsletter.id), target: '_blank', rel: 'noopener' }".html_safe do
      div(style: 'background: white') do
        content_tag(:iframe, '', src: preview_section_admin_newsletters_path(id: newsletter.id), width: '100%', height: '600px')
      end
    end

    panel "HTML preview, without social data - #{ link_to 'link', preview_section_admin_newsletters_path(id: newsletter.id, text: true), target: '_blank', rel: 'noopener' }".html_safe do
      div(style: 'background: white') do
        content_tag(:iframe, '', src: preview_section_admin_newsletters_path(id: newsletter.id, text: true), width: '100%', height: '600px')
      end
    end

    active_admin_comments

    render 'admin/shared/audits'
  end

  form do |f|
    f.inputs 'Newsletter' do
      f.semantic_errors(*f.object.errors.attribute_names)
      f.input :subject
      f.input :date, include_blank: false
      f.input :kind, as: :select, collection: Newsletter.kinds.keys, required: true, include_blank: false
      f.input :social_image, as: :file, hint: image_preview_hint(f.object.social_image_url, 'Recommended size: 600x315. Ratio 1.91:1.')
      f.input :skip_sponsor, as: :boolean, label: 'Skip Sponsor', hint: 'THIS WILL BLOCK ALL SPONSORS'
      f.input :sponsor_title, label: 'Sponsor Title', hint: 'Head Title for Sponsor Section'
      f.inputs 'Preview Token' do
        f.input :preview_token, as: :string, label: 'Preview Token', hint: "This will make a special link that people can view before newsletter is sent. Will be autogenerated if you leave it empty. Link will be: #{ newsletter_url(newsletter, preview: newsletter.preview_token) }"
      end
    end

    if f.object.persisted?
      div class: 'admin--newsletter-builder', id: 'newsletter-posts', 'data-posts' => Newsletter::Content::TopPostItem.from_array(f.object.posts).map { |post| { id: post.id, name: post.name, tagline: post.tagline, url: post_path(post) } }.to_json do
        div render('builder', newsletter: f.object)
        div class: 'admin--newsletter-builder--preview' do
          fieldset class: 'inputs' do
            legend content_tag(:span, 'Preview')
            div do
              content_tag(:iframe, '', src: preview_section_admin_newsletters_path(id: newsletter.id), width: '100%', height: '1600px', 'data-newsletter-preview' => true)
            end
          end
        end
      end
    end
    f.actions
  end

  action_item :new_import, only: :index do
    link_to 'Import Subscribers', action: 'new_import'
  end

  collection_action :new_import do
    @import = Admin::Newsletters::ImportCSV.new
  end

  collection_action :import, method: :post do
    @import = Admin::Newsletters::ImportCSV.new

    if @import.update params.require(:import).permit(:csv, :kind)
      redirect_to admin_newsletters_path, notice: "Imported #{ @import.import_count } subscribers with #{ @import.errors_count } errors. There were #{ @import.subscribed_count } already subscribed users."
    else
      render :new_import, import: @import
    end
  end
end
