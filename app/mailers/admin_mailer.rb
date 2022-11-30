# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def job_with_extra_packages(job)
    @job = job

    mail(
      to: CommunityContact::JOBS_CONTACT,
      subject: 'New job subscription with extra packages',
    )
  end

  def multi_factor_authentication(multi_factor_token)
    @multi_factor_token = multi_factor_token

    mail(
      to: multi_factor_token.user.subscriber.email,
      subject: 'Product Hunt multi factor authentication',
    )
  end
end
