# Hooksmith

**Hooksmith** is a modular, Rails-friendly gem for processing webhooks. It allows you to register multiple processors for different providers and events, ensuring that only one processor handles a given payload. If multiple processors qualify, an error is raised to avoid ambiguous behavior.

## Features

- **DSL for Registration:** Group processors by provider and event.
- **Flexible Dispatcher:** Dynamically selects the appropriate processor based on payload conditions.
- **Rails Integration:** Automatically configures with Rails using a Railtie.
- **Lightweight Logging:** Built-in logging that can be switched to `Rails.logger` when in a Rails environment.
- **Tested with Minitest:** 100% branch coverage for robust behavior.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hooksmith', '~> 0.1.1'
```

Then execute:
```bash
bundle install
```

Or install it yourself as:

```bash
gem install hooksmith
```

## Usage

### Configuration

Configure your webhook processors in an initializer (e.g., `config/initializers/hooksmith.rb`):

```ruby
Hooksmith.configure do |config|
  config.provider(:stripe) do |stripe|
    stripe.register(:charge_succeeded, 'Stripe::Processor::ChargeSucceeded::First')
    stripe.register(:charge_succeeded, 'Stripe::Processor::ChargeSucceeded::Second')
  end

  config.provider(:paypal) do |paypal|
    paypal.register(:payment_received, 'Paypal::Processor::PaymentReceived')
  end
end
```

### Persisting Webhook Events (Optional)

Hooksmith can optionally persist incoming webhook events to your database. Configure it with your own ActiveRecord model and mapping logic.

1) Create a model in your app (example):

```ruby
class WebhookEvent < ApplicationRecord
  self.table_name = 'webhook_events'
end
```

2) Example migration (customize fields as needed):

```ruby
create_table :webhook_events do |t|
  t.string   :provider
  t.string   :event
  t.jsonb    :payload
  t.datetime :received_at
  t.timestamps
  t.index    :event
  t.index    :received_at
end
```

3) Configure Hooksmith to record events:

```ruby
Hooksmith.configure do |config|
  config.event_store do |store|
    store.enabled = true
    store.model_class_name = 'WebhookEvent' # your model class
    store.record_timing = :before # :before, :after, or :both
    store.mapper = ->(provider:, event:, payload:) {
      {
        provider: provider.to_s,
        event: event.to_s,
        payload:,
        received_at: (Time.respond_to?(:current) ? Time.current : Time.now)
      }
    }
  end
end
```

## Implementing a Processor
Create a processor by inheriting from `Hooksmith::Processor::Base`:

```ruby
module Stripe
  module Processor
    module ChargeSucceeded
      class Tenant < Hooksmith::Processor::Base
        # Only handle events with a tenant_payment_id.
        def can_handle?(payload)
          payload.dig("metadata", "id").present?
        end

        def process!
          tenant_payment_id = payload.dig("metadata", "id")
          # Add your business logic here (e.g., update database records).
          puts "Processed id : #{id}"
        end
      end
    end
  end
end
```

## Dispatching a Webhook

Use the dispatcher in your webhook controller:

```ruby
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    provider = params[:provider] || "stripe"
    event    = params[:event]    || "charge_succeeded"
    payload  = params[:data]     # Adjust extraction as needed

    Hooksmith::Dispatcher.new(provider: provider, event: event, payload: payload).run!
    head :ok
  rescue Hooksmith::MultipleProcessorsError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
```

## Testing
The gem includes a full test suite using Minitest with 100% branch coverage. See the test/ directory for examples. You can run the tests with:

```
bundle exec rake test
```

If you want to check test coverage, you can integrate SimpleCov by adding the following at the top of your test/test_helper.rb:

```ruby
require "simplecov"
SimpleCov.start
```

Then run the tests to generate a coverage report.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/gregorypreve/hooksmith.


## License
The gem is available as open source under the terms of the MIT License.
