<p align="center">
  <img src="ruby/logo.png" alt="WhatsRB Cloud" width="80" />
</p>

<h1 align="center">WhatsRB Cloud SDKs</h1>

<p align="center">
  Official SDKs for the <a href="https://whatsrb.com">WhatsRB Cloud</a> API —<br/>
  the easiest way to integrate the official WhatsApp Business API.
</p>

<p align="center">
  <a href="https://readme.whatsrb.com">Documentation</a> &nbsp;&middot;&nbsp;
  <a href="https://whatsrb.com">Website</a> &nbsp;&middot;&nbsp;
  <a href="https://whatsrb.com/login">Dashboard</a>
</p>

<br />

## Packages

| SDK | Directory | Status | Install |
|-----|-----------|--------|---------|
| **Ruby** | [`ruby/`](./ruby) | `v0.1.0` | `gem "whatsrb_cloud"` |
| **JavaScript** | [`js/`](./js) | coming soon | `npm install @whatsrb/cloud` |

## Quick Start

**Ruby**

```ruby
require "whatsrb_cloud"

client = WhatsrbCloud::Client.new(api_key: "wrb_live_xxx")

# Send a WhatsApp message via Business API
account = client.business_accounts.list.data.first
account.send_text(to: "+33612345678", text: "Hello from WhatsRB!")

# Or via a personal session
session = client.sessions.create(name: "My Bot")
session.wait_for_qr(timeout: 60) { |qr| puts "Scan: #{qr}" }
session.send_message(to: "+33612345678", text: "Hello!")
```

**JavaScript** *(coming soon)*

```ts
import { createClient } from "@whatsrb/cloud"

const client = createClient({ apiKey: "wrb_live_xxx" })

const accounts = await client.businessAccounts.list()
await accounts.data[0].sendText({ to: "+33612345678", text: "Hello!" })
```

## Documentation

Full guides and API reference at **[readme.whatsrb.com](https://readme.whatsrb.com)**:

- [Getting Started](https://readme.whatsrb.com)
- [Authentication](https://readme.whatsrb.com/guides/authentication)
- [Webhooks](https://readme.whatsrb.com/guides/webhooks)
- [Ruby SDK](https://readme.whatsrb.com/sdks/ruby/overview)
- [API Reference](https://readme.whatsrb.com/api-reference/overview)

## Repository Structure

```
whatsrb-sdk/
├── ruby/   # Ruby gem — whatsrb_cloud
└── js/     # TypeScript/JS package — @whatsrb/cloud
```

Each SDK is independently versioned and published to its respective registry.

## License

MIT — see individual SDK directories for details.
