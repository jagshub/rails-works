# How to run a A/B Test?

1. Add **test_name** & **variants** to `AbTest` _(domain/ab_test.rb)_

   Exampe:

   ```rb
   TESTS = {
       'experiment_1` => %w(control variant1 variant 2)
   }
   ```

   > In the above example test name is experiment_1 & it has the variants control, variant1 & variant 2.

   **If you test isn't active go to `/admin/split` -> `Start`**

2. In frontend use `useAbTest` hook to get the variant for a user.
   ```jsx
   const { variant, complete } = useAbTest({testName: 'experiment_1});
   ```
3. And by default the AbTest domain will look if there is feature flag with pattern
   `ab_<split_test_name>` so for above case we will look if `ab_experiment_1` exists and **if feature flag is disabled we will return first variant which should be control i.e. default or existing.**
4. Now to start the experiment go to [Split Dashboard](https://www.producthunt.com/admin/split) and click on the `start` button near your experiment.

## Feature flag

A/B test system will look for feature flag by default. So if you need to use flipper. Create a feature flag with the following name pattern `ab_<split_test_name>`

### Working

- If no feature flag is present, split will pick the variant.
- If feature flag is present and disabled then we will return first variant which is control.
- If feature flag is present and enabled then split will pick the variant.

## Data tracking

1. You can find testing related stats in `admin/split` under your experiment name.
2. We store the experiment participants data in `ab_test_participants` table.
