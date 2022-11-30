# Stream::Activities - Activity

This object is used to fan out your event to users as notifications

# Definitiy

### verb

This is a string key used to identify your activity type. When you create a new verb, add it to feed_items.rb

```
app/models/stream/feed_item.rb:64
```

This will append to a gql enum which will notify you where to create the component to display this activity

Also add it to feed_items_sync_data at

```
app/services/stream/workers/feed_items_sync_data.rb:50
```

Which will append additional information required for your notification to become visible

### create_when

WIP <- I'm not sure what this does yet

### notify_user_id

This field receives a block with three arguments

```
event - the original event object
target - the target object
actor - the user of the event
```

Expects an array of user_ids to be notified. Return empty array if no one should be notified

### target

Define the target object, generally this is `event.subject` (which is also the object key)

### connecting_text

This field receives a block with three arguments

```
receive_id - user to be receiving this activity
object - the subject of the event
target - the target object
```
