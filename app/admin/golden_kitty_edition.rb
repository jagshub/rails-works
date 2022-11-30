# frozen_string_literal: true

ActiveAdmin.register GoldenKitty::Edition do
  menu label: 'Edition', parent: 'Golden Kitty'

  actions :all, except: :destroy

  permit_params %i(
    year
    nomination_starts_at
    nomination_ends_at
    voting_starts_at
    voting_ends_at
    live_event_at
    result_at
    card_image
    social_image
    social_image_nomination
    social_image_pre_voting
    social_image_voting
    social_image_pre_result
    social_image_result
    social_share_text
    social_text_nomination_started
    social_text_nomination_ended
    social_text_voting_started
    social_text_voting_ended
    social_text_result_announced
    results_url
    results_description
  )

  config.per_page = 20
  config.paginate = true

  filter :year

  index do
    column :id
    column :year

    actions
  end

  show do
    attributes_table do
      row :id
      row :year
      row :nomination_starts_at
      row :nomination_ends_at
      row :voting_starts_at
      row :voting_ends_at
      row :live_event_at
      row :result_at
      row :card_image do |edition|
        if edition.card_image.present?
          link_to(
            image_tag(edition.card_image_url, height: 100, width: 'auto'),
            edition.card_image_url,
            target: '_blank',
            rel: 'noopener',
          )
        end
      end
      GoldenKitty::Edition.social_image_columns.map do |c|
        row c.to_sym do |edition|
          if edition.send(c).present?
            link_to(
              image_tag(edition.send("#{ c }_url"), height: 100, width: 'auto'),
              edition.send("#{ c }_url"),
              target: '_blank',
              rel: 'noopener',
            )
          end
        end
      end
      GoldenKitty::Edition.social_share_text_columns.map do |c|
        row c.to_sym
      end
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :year
    end

    f.inputs  'Timeline' do
      f.input :nomination_starts_at, as: :datetime_picker
      f.input :nomination_ends_at, as: :datetime_picker
      f.input :voting_starts_at, as: :datetime_picker
      f.input :voting_ends_at, as: :datetime_picker
      f.input :live_event_at, as: :datetime_picker
      f.input :result_at, as: :datetime_picker
      f.input :results_url, hint: 'Will be used in History page'
      f.input :results_description, hint: 'Will be used in History page'
    end

    f.inputs 'Social Image' do
      f.input :card_image, as: :file, hint: image_preview_hint(f.object.card_image_url, 'Square image for product activity feed card')
      f.input :social_image, as: :file, hint: image_preview_hint(f.object.social_image_url, 'Default Social Image')
      f.input :social_image_nomination, as: :file, hint: image_preview_hint(f.object.social_image_nomination_url, 'During nomination this will be used')
      f.input :social_image_pre_voting, as: :file, hint: image_preview_hint(f.object.social_image_pre_voting_url, 'Between nomination end  & voting start this will be used')
      f.input :social_image_voting, as: :file, hint: image_preview_hint(f.object.social_image_voting_url, 'During voting  this will be used')
      f.input :social_image_pre_result, as: :file, hint: image_preview_hint(f.object.social_image_pre_result_url, 'Between voting end & result announced this will be used')
      f.input :social_image_result, as: :file, hint: image_preview_hint(f.object.social_image_result_url, 'When result announced this will be used')
    end

    f.inputs 'Social share text' do
      f.input :social_share_text
      f.input :social_text_nomination_started
      f.input :social_text_nomination_ended
      f.input :social_text_voting_started
      f.input :social_text_voting_ended
      f.input :social_text_result_announced
    end

    f.actions
  end

  action_item :send_gk_open, only: :show do
    link_to 'Send Nomination Open Email', send_gk_open_admin_golden_kitty_edition_path(resource), data: { confirm: 'Are you sure you want to send nomination open email?' }
  end

  member_action :send_gk_open do
    GoldenKitty.schedule_send_email_notification 'nomination_started', resource

    redirect_to admin_golden_kitty_edition_path(resource), notice: 'Email sent!'
  end

  action_item :send_gk_voting_open, only: :show do
    link_to 'Send Voting Open Email', send_gk_voting_open_admin_golden_kitty_edition_path(resource), data: { confirm: 'Are you sure you want to send voting open email?' }
  end

  member_action :send_gk_voting_open do
    GoldenKitty.schedule_send_email_notification 'voting_started', resource

    redirect_to admin_golden_kitty_edition_path(resource), notice: 'Email sent!'
  end
end
