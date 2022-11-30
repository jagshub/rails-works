# User badges
User badges is the system responsible for profile badges award to users. [Example](https://www.producthunt.com/@rrhoover/badges)

### Creating a new badge
Choose an identifier in underscore: `new_badge`. Add this constant

```ruby
# app/models/badges/award.rb
class Badges::Award < ApplicationRecord
  ...
  # NOTE! This was built as an enum array, and so order here matters. Add your enum
  # value at the end of the array ONLY!! A great example of why we ALWAYS use hash notation
  enum identifiers: [
    ...
    'new_badge',
  ].freeze
end

# app/domain/user_badges.rb
module UserBadges
  extend self

  AWARDS = {
    'new_badge' => UserBadges::Badge::NewBadge, # Award logic, defined later
  }.freeze
end
```

Define your award logic
```ruby
# frozen_string_literal: true

module UserBadges::Badge::NewBadge
  extend UserBadges::Badge::Base
  extend self

  # Status assigned at creation
  DEFAULT_STATUS = :awarded_to_user_and_visible  

  # Additional keys in the #data jsonb column, along with validation. Structure
  # is a hash of key to proc for validating.
  REQUIRED_KEYS = {                              
    identifier: ->(val) { val == UserBadges::AWARDS.index(self) },
  }.freeze

  # Boolean control if badges can be combined
  def stackable?
    true
  end

  # Validates the award, call `required_keys?` and `valid_key_values?` to validate
  # based on `REQUIRED_KEYS`
  def validate?(data:, user:)
    required_keys?(data) && valid_key_values?(data)
    # ... other validations
  end

  # Callback for the create method. Define logic related to creation of record
  # such as updating counters
  def update_or_create(data:, user:)
    Badges::UserAwardBadge.create_or_find_by!(
      subject: user,
      data: data,
    )
    # ... do other stuff
  end

  # Add definition for when badge is awarded if there should be email and notification
  # items
  def send_notifications?
    false # default true
  end
end
```

You cannot create award records through admin as code deploy is required, but you can [edit](https://producthunt.com/admin/badges_awards) after. Use a rails task
to create your record

```ruby
# lib/tasks/data_migrations/create_new_badge_badge.rake
namespace :data_migrations do
  task create_new_badge_badge: :environment do
    Badges::Award.create_or_find_by!(
      identifier: 'new_badge',                      # Your identifier
      name: 'New Badge',                            
      description: '???',
      image_uuid: 'placeholder_until_upload.jpg',   # You can upload to s3 and save the key, or just add placeholder.
      active: true,
    )
  end
```