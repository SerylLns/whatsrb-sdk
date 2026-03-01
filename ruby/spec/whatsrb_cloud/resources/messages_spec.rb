# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Resources::Messages do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }
  let(:messages) { client.messages('sess_abc') }

  describe '#list' do
    it 'returns a List of Message objects' do
      FakeServer.stub_get('/sessions/sess_abc/messages', response: {
                            'data' => [
                              { 'id' => 'msg_1', 'to' => '+33600000001', 'status' => 'sent', 'message_type' => 'text' },
                              { 'id' => 'msg_2', 'to' => '+33600000002', 'status' => 'delivered',
                                'message_type' => 'image' }
                            ],
                            'meta' => { 'total' => 2 }
                          })

      list = messages.list
      expect(list).to be_a(WhatsrbCloud::Objects::List)
      expect(list.data.size).to eq(2)
      expect(list.data.first).to be_a(WhatsrbCloud::Objects::Message)
      expect(list.data.first.to).to eq('+33600000001')
    end
  end

  describe '#retrieve' do
    it 'returns a Message object, unwrapping data' do
      FakeServer.stub_get('/sessions/sess_abc/messages/msg_1', response: {
                            'data' => {
                              'id' => 'msg_1', 'to' => '+33600000001', 'status' => 'sent',
                              'message_type' => 'text', 'content' => 'Hello!'
                            }
                          })

      msg = messages.retrieve('msg_1')
      expect(msg.id).to eq('msg_1')
      expect(msg.content).to eq('Hello!')
      expect(msg.message_type).to eq('text')
    end
  end

  describe '#create' do
    it 'sends a text message with text: shorthand' do
      stub = stub_request(:post, "#{FakeServer::BASE}/sessions/sess_abc/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"text","content":"Hello!"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_new","to":"+33600000001","status":"queued","message_type":"text"}}',
                        headers: FakeServer.json_headers)

      msg = messages.create(to: '+33600000001', text: 'Hello!')
      expect(msg).to be_a(WhatsrbCloud::Objects::Message)
      expect(msg.id).to eq('msg_new')
      expect(stub).to have_been_requested
    end

    it 'sends an image message with explicit message_type' do
      stub = stub_request(:post, "#{FakeServer::BASE}/sessions/sess_abc/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"image","content":"https://img.example.com/photo.jpg"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_img","message_type":"image"}}',
                        headers: FakeServer.json_headers)

      messages.create(to: '+33600000001', message_type: 'image', content: 'https://img.example.com/photo.jpg')
      expect(stub).to have_been_requested
    end

    it 'sends a document message' do
      stub = stub_request(:post, "#{FakeServer::BASE}/sessions/sess_abc/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"document","content":"https://example.com/doc.pdf"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_doc","message_type":"document"}}',
                        headers: FakeServer.json_headers)

      messages.create(to: '+33600000001', message_type: 'document', content: 'https://example.com/doc.pdf')
      expect(stub).to have_been_requested
    end
  end
end
