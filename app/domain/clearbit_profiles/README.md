# Clearbit Person Profiles

This domain operates on `Clearbit::PersonProfile`, or the underlying table `clearbit_person_profiles`.

## Enrich

This class fetches profiles via emails or webhook payloads

#### from_email/2

Parameters

```
email -> a string email.
  Will get downcase before run
refresh -> an optional boolean, default false.
  Will force a clearbit api request if true
stream -> an optional boolean, default false.
  Will use clearbit stream API, which will hold open connection until a response. This method is good for jobs that make many requests as it will not be rate limited
```

**Notes**
Clearbit will sometimes return a promise of a response if we're over the api limit (unless you're using `stream`). In this case, this method will return nil. A follow up response will be return via the webhook job [app/workers/web_hooks/clearbit_worker.rb](https://github.com/producthunt/producthunt/blob/master/app/workers/web_hooks/clearbit_worker.rb).

Clearbit docs [here](https://dashboard.clearbit.com/docs#api-reference)

#### from_payload/2

Parameters

```
payload -> a response payload,
  from the clearbit webhook worker Webhooks::ClearbitWorker
email -> an optional string email, default nil.
  Will be used in creating the profile of `ClearbitProfiles`. If left blank, the payload email will be used.
```
