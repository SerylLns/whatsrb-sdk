# frozen_string_literal: true

RSpec.describe WhatsrbCloud::WebhookSignature do
  let(:secret) { 'whsec_test_secret' }
  let(:payload) { '{"event":"message.received","data":{"id":"msg_1"}}' }
  let(:hex) { OpenSSL::HMAC.hexdigest('SHA256', secret, payload) }
  let(:prefixed_signature) { "sha256=#{hex}" }

  describe '.verify?' do
    it 'returns true for a prefixed sha256= signature' do
      expect(described_class.verify?(payload: payload, secret: secret, signature: prefixed_signature)).to be true
    end

    it 'returns false for a raw hex signature without sha256= prefix' do
      expect(described_class.verify?(payload: payload, secret: secret, signature: hex)).to be false
    end

    it 'returns false for an invalid signature' do
      expect(described_class.verify?(payload: payload, secret: secret, signature: 'sha256=invalid')).to be false
    end

    it 'returns false for a tampered payload' do
      tampered = '{"event":"message.received","data":{"id":"msg_HACKED"}}'
      expect(described_class.verify?(payload: tampered, secret: secret, signature: prefixed_signature)).to be false
    end

    it 'returns false for a wrong secret' do
      expect(described_class.verify?(payload: payload, secret: 'wrong_secret',
                                     signature: prefixed_signature)).to be false
    end

    it 'returns false when signature is nil' do
      expect(described_class.verify?(payload: payload, secret: secret, signature: nil)).to be false
    end

    it 'returns false when payload is nil' do
      expect(described_class.verify?(payload: nil, secret: secret, signature: prefixed_signature)).to be false
    end

    it 'returns false when secret is nil' do
      expect(described_class.verify?(payload: payload, secret: nil, signature: prefixed_signature)).to be false
    end
  end

  describe '.verify_request' do
    let(:body_io) { StringIO.new(payload) }
    let(:request) do
      double(body: body_io).tap do |r|
        allow(r).to receive(:get_header).with('HTTP_X_WHATSRB_SIGNATURE').and_return(prefixed_signature)
        allow(r).to receive(:get_header).with('HTTP_X_WEBHOOK_SIGNATURE').and_return(nil)
        allow(r).to receive(:get_header).with('HTTP_X_WEBHOOK_TIMESTAMP').and_return(nil)
      end
    end

    it 'verifies a Rack-compatible request' do
      expect(described_class.verify_request(request, secret: secret)).to be true
    end

    it 'rewinds the body after reading' do
      described_class.verify_request(request, secret: secret)
      expect(request.body.read).to eq(payload)
    end

    it 'returns false for invalid signature' do
      allow(request).to receive(:get_header).with('HTTP_X_WHATSRB_SIGNATURE').and_return('sha256=bad')
      expect(described_class.verify_request(request, secret: secret)).to be false
    end

    it 'falls back to X-Webhook-Signature header' do
      allow(request).to receive(:get_header).with('HTTP_X_WHATSRB_SIGNATURE').and_return(nil)
      allow(request).to receive(:get_header).with('HTTP_X_WEBHOOK_SIGNATURE').and_return(prefixed_signature)
      expect(described_class.verify_request(request, secret: secret)).to be true
    end
  end
end
