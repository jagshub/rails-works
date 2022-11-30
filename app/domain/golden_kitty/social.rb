# frozen_string_literal: true

module GoldenKitty::Social
  extend self
  def image_for(edition:, subject:)
    image = case edition.phase
            when :nomination_started then subject.social_image_nomination_uuid
            when :nomination_ended then subject.social_image_pre_voting_uuid
            when :voting_started
              if !subject.instance_of?(GoldenKitty::Category) || subject.voting_enabled?
                subject.social_image_voting_uuid
              else
                subject.social_image_pre_voting_uuid
              end
            when :voting_ended then subject.social_image_pre_result_uuid
            when :result_announced then subject.social_image_result_uuid
            end

    image || default_image(subject)
  end

  def text_for(edition:, subject:)
    text = case edition.phase
           when :nomination_started then subject.social_text_nomination_started
           when :nomination_ended then subject.social_text_nomination_ended
           when :voting_started
             if !subject.instance_of?(GoldenKitty::Category) || subject.voting_enabled?
               subject.social_text_voting_started
             else
               subject.social_text_nomination_ended
             end
           when :voting_ended then subject.social_text_voting_ended
           when :result_announced then subject.social_text_result_announced
           end

    text || subject.social_share_text
  end

  private

  def default_image(subject)
    subject.social_image_uuid
  end
end
