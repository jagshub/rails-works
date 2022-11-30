# Development

You can enable syncing on development. Please note updating the index will 
update a development version of the index on elastic cloud (index names have the 
environment appended e.g. `products_development`). This will affect other 
developers

```
# Start your server with
INDEX_ELASTICSEARCH=1 rails server

# Also start sidekiq with queue search_export if you're planning to use batching
bundle exec sidekiq -q search_export
```

## ActiveRecord Concern
This domain contains an activerecord concern [Search::Searchable](app/domain/search/searchable.rb)

Example configuration

```ruby
  extension Search.searchable
```

### only 
If you want to limit the records that are index, you can do so by defining
a scope and pass into `:only` option

```ruby
  extension Search.searchable, only: :searchable
  
  scope :searchable, -> { not_trashed }
```

### searchable_data
Defining `#searchable_data` method using the `Search.document` helper.

```ruby
  extension Search.searchable

  def searchable_data
    Search.document(self, {
      # Add overrides
      name: "#{ self.title } - #{ self.tagline }",
    })
  end
```

IMPORTANT: Any updates to `#searchable_data` will require reindexing.

### includes
If your searchable data uses associations, you can pass `:includes` into the
extension to prevent N+1 queries during syncing.

```ruby
  extension Search.searchable, includes: %i(user comments)

  def searchable_data
    Search.document(self, {
      comments: comments.map(&:body),
      user: user.name,
    }) 
  end
```

### if
Some models have a lot of counter caches, and ones that update often (User). You may not want to reindex them all the time.

```ruby
  extension Search.searchable, if: :should_reindex?
  extension Search.searchable_association :items, if: :should_reindex?

  def should_reindex
    # NOTE(DZ): Slightly faster than #intersection
    (KEYS_TO_INDEX - saved_changes.keys).size < KEYS_TO_INDEX.size
  end
```

### Associations
Sometimes, records depend on other records' data for indexing. Add this

```ruby
  belongs_to :thing
  has_many :others

  extension(
    Search.searchable_association, 
    associations: %i(thing others), 
    if: :should_reindex_associations?,
  )

  # This is called as `after_save` callback. The `saved_change_to_` method works
  # well here for `create` and `update`. This method will not be used for 
  # `after_destroy`
  def should_reindex_associations?
    saved_change_to_my_column?
  end
```

### Rspec Testing
A shared example is available for models. It checks your `#searchable_data` 
method for N+1 and return type. Use it like.

```ruby
require 'models/shared_examples/searchable_model'

describe UpcomingPage do
  it_behaves_like 'a searchable model', :upcoming_page
end
```

# Helpful commands
[Searchkick](https://github.com/ankane/searchkick) also includes some helper 
methods. See their README for more information

```ruby
# Index everything
Product.reindex

# Delete an index
Product.search_index.delete

# Index a single record
Product.last.reindex

# Removing a single record from index
Product.search_index.remove(Product.last)

# Search one model
Search::Query.new(query, model: [Product])

# Searching with debug
Search::Query.new(query).execute(debug: true)

# Get raw results from search
Search::Query.new(query).execute(load: false)

Search.without_indexing do
  # Do things without triggering updates
end
```

# Other notes and TODOs:
1) We current do not support search routing (as we have 1 live node).
[documentation](https://www.elastic.co/blog/customizing-your-document-routing)
2) We do not implement `position_increment_gap` 
[documentation](https://www.elastic.co/guide/en/elasticsearch/guide/current/_multivalue_fields_2.html)