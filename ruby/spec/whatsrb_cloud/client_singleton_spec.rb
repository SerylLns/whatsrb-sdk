# frozen_string_literal: true

RSpec.describe 'WhatsrbCloud.client' do
  before do
    WhatsrbCloud.configure { |c| c.api_key = 'wrb_live_test' }
  end

  it 'returns a Client instance' do
    expect(WhatsrbCloud.client).to be_a(WhatsrbCloud::Client)
  end

  it 'returns the same instance on repeated calls' do
    expect(WhatsrbCloud.client).to equal(WhatsrbCloud.client)
  end

  it 'resets client on reset_configuration!' do
    first = WhatsrbCloud.client
    WhatsrbCloud.reset_configuration!
    WhatsrbCloud.configure { |c| c.api_key = 'wrb_live_test' }
    expect(WhatsrbCloud.client).not_to equal(first)
  end
end
