# frozen_string_literal: true

module ClearbitProfiles::Enrich
  extend self

  def from_email(email, refresh: false, stream: false)
    profile = Clearbit::PersonProfile.find_by(email: email)
    return profile unless profile.blank? || refresh

    fetch_and_persist_profile(email, stream)
  end

  def from_payload(payload)
    payload_email = payload&.dig('person', 'email')
    return if payload_email.blank?

    HandleRaceCondition.call do
      profile = update_or_create_profile(payload['person'], payload['company'])
      UpcomingPages::Enrichment.update_contacts(payload_email, profile)

      profile
    end
  end

  private

  def fetch_and_persist_profile(email, stream)
    payload = External::ClearbitAPI.person_company(email, stream: stream)

    from_payload(payload&.to_h)
  end

  def update_or_create_profile(person, company = nil)
    profile = Clearbit::PersonProfile.find_or_initialize_by(
      email: person['email'],
    )

    profile.update!(
      clearbit_id: person['id'],
      name: person['name']['fullName'],
      email: person['email'].downcase,
      gender: person['gender'],
      bio: person['bio'],
      site: person['site'],
      avatar_url: person['avatar'],
      employment_name: person['employment']['name'],
      employment_title: person['employment']['title'],
      employment_domain: person['employment']['domain'],
      employment_seniority: person['employment']['seniority'],
      employment_role: person['employment']['role'],
      geo_city: person['geo']['city'],
      geo_state: person['geo']['state'],
      geo_country: person['geo']['country'],
      github_handle: person['github']['handle'],
      twitter_handle: person['twitter']['handle'],
      linkedin_handle: person['linkedin']['handle'],
      gravatar_handle: person['gravatar']['handle'],
      aboutme_handle: person['aboutme']['handle'],
      indexed_at: Time.zone.parse(person['indexedAt']),
    )

    if company
      company_profile = Clearbit::CompanyProfile.find_or_initialize_by(
        domain: company['domain'],
      )

      begin
        company_profile_update(company, company_profile)
      rescue ActiveRecord::RecordNotUnique
        company_profile = Clearbit::CompanyProfile.find_by(
          domain: company['domain'],
        )
        company_profile_update(company, company_profile)
      end

      profile.company = company_profile
    end

    profile
  end

  def company_profile_update(company, company_profile)
    company_profile.update!(
      clearbit_id: company['id'],
      name: company['name'],
      legal_name: company['legalName'],
      category_sector: company['category']['sector'],
      category_industry: company['category']['industry'],
      category_sub_industry: company['category']['subIndustry'],
      geo_country: company['geo']['country'],
      metrics_employees: company['metrics']['employees'],
      metrics_employees_range: company['metrics']['employeesRange'],
      metrics_estimated_annual_revenue: company['metrics']['estimatedAnnualRevenue'],
      founded_year: company['foundedYear'],
      indexed_at: Time.zone.parse(company['indexedAt']),
    )
  end
end
