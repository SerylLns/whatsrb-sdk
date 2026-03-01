# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Resources::BusinessMessages do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }
  let(:messages) { client.business_messages('ba_abc') }

  describe '#list' do
    it 'returns a List of Message objects' do
      FakeServer.stub_get('/business_accounts/ba_abc/messages', response: {
                            'data' => [
                              { 'id' => 'msg_1', 'to' => '+33600000001', 'status' => 'sent', 'message_type' => 'text' },
                              { 'id' => 'msg_2', 'to' => '+33600000002', 'status' => 'delivered', 'message_type' => 'template' }
                            ],
                            'meta' => { 'total' => 2 }
                          })

      list = messages.list
      expect(list).to be_a(WhatsrbCloud::Objects::List)
      expect(list.data.size).to eq(2)
      expect(list.data.first).to be_a(WhatsrbCloud::Objects::Message)
    end

    it 'supports errors_only filter' do
      stub = stub_request(:get, "#{FakeServer::BASE}/business_accounts/ba_abc/messages?errors_only=true")
             .to_return(status: 200,
                        body: '{"data":[{"id":"msg_err","status":"failed"}],"meta":{"total":1}}',
                        headers: FakeServer.json_headers)

      list = messages.list(errors_only: true)
      expect(list.data.size).to eq(1)
      expect(stub).to have_been_requested
    end
  end

  describe '#retrieve' do
    it 'returns a Message object' do
      FakeServer.stub_get('/business_accounts/ba_abc/messages/msg_1', response: {
                            'data' => {
                              'id' => 'msg_1', 'to' => '+33600000001', 'status' => 'sent',
                              'message_type' => 'text', 'content' => 'Hello!', 'direction' => 'outbound'
                            }
                          })

      msg = messages.retrieve('msg_1')
      expect(msg.id).to eq('msg_1')
      expect(msg.content).to eq('Hello!')
      expect(msg.direction).to eq('outbound')
    end
  end

  describe '#create' do
    it 'sends a text message' do
      stub = stub_request(:post, "#{FakeServer::BASE}/business_accounts/ba_abc/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"text","content":"Hello!"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_new","to":"+33600000001","status":"queued","message_type":"text"}}',
                        headers: FakeServer.json_headers)

      msg = messages.create(to: '+33600000001', message_type: 'text', content: 'Hello!')
      expect(msg).to be_a(WhatsrbCloud::Objects::Message)
      expect(msg.id).to eq('msg_new')
      expect(stub).to have_been_requested
    end

    it 'sends a template message' do
      stub = stub_request(:post, "#{FakeServer::BASE}/business_accounts/ba_abc/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"template","template_name":"hello","template_language":"en"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_tpl","message_type":"template"}}',
                        headers: FakeServer.json_headers)

      messages.create(to: '+33600000001', message_type: 'template', template_name: 'hello', template_language: 'en')
      expect(stub).to have_been_requested
    end

    it 'raises ValidationError for missing phone number' do
      expect {
        messages.create(to: '', message_type: 'text', content: 'Hello!')
      }.to raise_error(WhatsrbCloud::ValidationError, 'Phone number is required')
    end

    it 'raises ValidationError for invalid phone format' do
      expect {
        messages.create(to: 'not_a_phone', message_type: 'text', content: 'Hello!')
      }.to raise_error(WhatsrbCloud::ValidationError, 'Invalid phone number format')
    end

    it 'raises ValidationError for invalid message type' do
      expect {
        messages.create(to: '+33600000001', message_type: 'invalid', content: 'x')
      }.to raise_error(WhatsrbCloud::ValidationError, 'Invalid message type: invalid')
    end
  end
end
