# Domain logic

This folder contains a collection of bounded contexts in the ProductHunt domain. Any domain logic should be used through these entry points and delegate to models, services, etc.

## New domain objects

To create a new domain module, make a new folder with the namespace you desire. **It is preferable that the namespace is pluralized**.

**Your entry file should be named the same as your domain and placed in directly in app/domain**, for example `app/domain/[domain].rb`. This is necessary for autoloading to pick up your file. You could create additional folders under `app/domain/[domain]/**` that would be considered "private".

Methods inside your domain module should use named parameters.

### Example

```
/domain
|- /ads
|- |- module.rb
|- ads.rb
```

```ruby
# in domain/ads.rb
module Ads
  extend self

  def some_function(param_a:, param_b:)
    # do some stuff
    Ads::Module.some_function(param_a, param_b)
  end
end
```
