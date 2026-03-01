<p align="center">
  <img src="logo.png" alt="WhatsRB Cloud" width="80" />
</p>

<h1 align="center">WhatsRB Cloud Ruby SDK</h1>

<h4 align="center">Official Ruby client for the <a href="https://whatsrb.com">WhatsRB Cloud</a> API.</h4>

<p align="center">
  Send WhatsApp messages, manage sessions, and handle webhooks — all from Ruby.
</p>

<p align="center">
  <a href="https://github.com/SerylLns/whatsrb-cloud-ruby/actions/workflows/ci.yml"><img src="https://github.com/SerylLns/whatsrb-cloud-ruby/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-22c55e" alt="License" /></a>
  <a href="https://www.ruby-lang.org"><img src="https://img.shields.io/badge/ruby-%3E%3D%203.1-CC342D?logo=ruby&logoColor=white" alt="Ruby" /></a>
</p>

<p align="center">
  <a href="https://whatsrb.com">Website</a> &nbsp;&middot;&nbsp;
  <a href="https://whatsrb.com/docs">Documentation</a> &nbsp;&middot;&nbsp;
  <a href="https://github.com/SerylLns/whatsrb-cloud-ruby">Source</a>
</p>

<br />

## Installation

Add to your Gemfile:

```ruby
gem "whatsrb_cloud", git: "https://github.com/SerylLns/whatsrb-cloud-ruby"
```

Then run `bundle install`.

## Quick Start

```ruby
require "whatsrb_cloud"

client = WhatsrbCloud::Client.new(api_key: "wrb_live_xxx")

# Create a session
session = client.sessions.create(name: "My Bot")

# Wait for QR code scan
session.wait_for_qr(timeout: 60) do |qr_data|
  puts "Scan this QR code: #{qr_data}"
end

# Send a message
session.send_message(to: "+33612345678", text: "Hello from WhatsRB!")
```

## Configuration

### Global configuration

```ruby
WhatsrbCloud.configure do |c|
  c.api_key  = "wrb_live_xxx"
  c.base_url = "https://api.whatsrb.com"  # default
  c.timeout  = 30                          # seconds, default
end

client = WhatsrbCloud::Client.new
```

### Per-client configuration

```ruby
client = WhatsrbCloud::Client.new(
  api_key:  "wrb_live_xxx",
  base_url: "https://api.whatsrb.com",
  timeout:  10
)
```

### Dev mode (local testing)

Point the client to your local WhatsRB Cloud server:

```ruby
# Global
WhatsrbCloud.configure do |c|
  c.api_key  = "wrb_test_xxx"
  c.base_url = "http://localhost:3000"
end

# Or per-client
client = WhatsrbCloud::Client.new(
  api_key:  "wrb_test_xxx",
  base_url: "http://localhost:3000"
)
```

## Sessions

```ruby
# List all sessions
list = client.sessions.list
list.data   # => [Session, ...]
list.meta   # => { "total" => 3, "plan_limit" => 5 }

# Create a session
session = client.sessions.create(name: "Support Bot")

# Retrieve a session
session = client.sessions.retrieve("sess_abc")
session.id              # => "sess_abc"
session.status          # => "connected"
session.connected?      # => true
session.phone_number    # => "+33612345678"

# Delete a session
client.sessions.delete("sess_abc")
```

### QR Code Polling

```ruby
session = client.sessions.create(name: "New Bot")

session.wait_for_qr(timeout: 60, interval: 2) do |qr_data|
  # qr_data is base64-encoded — display or convert as needed
  puts "Please scan: #{qr_data}"
end

puts "Connected! Phone: #{session.phone_number}"
```

## Messages

```ruby
# Via client (scoped to a session)
messages = client.messages("sess_abc")
messages.list
messages.retrieve("msg_xyz")
messages.create(to: "+33612345678", text: "Hello!")

# Via session object
session.send_message(to: "+33612345678", text: "Hello!")
session.send_image(to: "+33612345678", url: "https://example.com/photo.jpg", caption: "Check this!")
session.send_document(to: "+33612345678", url: "https://example.com/doc.pdf", filename: "invoice.pdf")
session.send_video(to: "+33612345678", url: "https://example.com/video.mp4")
session.send_audio(to: "+33612345678", url: "https://example.com/audio.ogg")
session.send_location(to: "+33612345678", latitude: 48.8566, longitude: 2.3522)
session.send_contact(to: "+33612345678", name: "John Doe", phone: "+33698765432")
```

### Message object

```ruby
msg = messages.retrieve("msg_xyz")
msg.id              # => "msg_xyz"
msg.to              # => "+33612345678"
msg.status          # => "sent"
msg.message_type    # => "text"
msg.content         # => "Hello!"
msg.sent_at         # => Time or nil
msg.delivered_at    # => Time or nil
```

## Webhooks

```ruby
# List
client.webhooks.list

# Create
wh = client.webhooks.create(url: "https://example.com/webhook", events: ["message.received"])
wh.secret   # => "whsec_..." (only returned on create)

# Retrieve
client.webhooks.retrieve("wh_123")

# Update
client.webhooks.update("wh_123", events: ["message.received", "session.connected"])

# Delete
client.webhooks.delete("wh_123")
```

### Webhook Signature Verification

Verify incoming webhooks in your application:

```ruby
# Rails controller example
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload   = request.body.read
    signature = request.headers["X-Webhook-Signature"]

    unless WhatsrbCloud::WebhookSignature.verify?(payload: payload, secret: "whsec_xxx", signature: signature)
      head :unauthorized
      return
    end

    event = JSON.parse(payload)
    # Handle the event...

    head :ok
  end
end
```

## Usage

```ruby
usage = client.usage
usage["messages_sent"]     # => 150
usage["sessions_active"]   # => 3
usage["plan"]              # => "pro"
```

## Error Handling

```ruby
begin
  client.sessions.retrieve("sess_nonexistent")
rescue WhatsrbCloud::AuthenticationError => e
  # 401 — Invalid API key
rescue WhatsrbCloud::ForbiddenError => e
  # 403 — Plan limit reached
rescue WhatsrbCloud::NotFoundError => e
  # 404 — Resource not found
rescue WhatsrbCloud::ValidationError => e
  # 422 — Invalid parameters
rescue WhatsrbCloud::ConflictError => e
  # 409 — Session not connected
rescue WhatsrbCloud::RateLimitError => e
  # 429 — Rate limited
  puts "Retry after #{e.retry_after} seconds"
rescue WhatsrbCloud::ServerError => e
  # 5xx — Server error
rescue WhatsrbCloud::Error => e
  # Catch-all
  puts "#{e.message} (status: #{e.status})"
end
```

## Development

```sh
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT License. See [LICENSE](LICENSE).
