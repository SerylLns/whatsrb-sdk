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
end
