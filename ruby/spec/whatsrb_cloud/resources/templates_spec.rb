# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Resources::Templates do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }
  let(:templates) { client.templates('ba_abc') }

  describe '#list' do
    it 'returns a List of Template objects' do
      FakeServer.stub_get('/business_accounts/ba_abc/templates', response: {
                            'data' => [
                              { 'id' => 'tpl_1', 'name' => 'hello', 'status' => 'approved', 'category' => 'utility', 'language' => 'en' },
                              { 'id' => 'tpl_2', 'name' => 'promo', 'status' => 'pending', 'category' => 'marketing', 'language' => 'fr' }
                            ],
                            'meta' => { 'total' => 2 }
                          })

      list = templates.list
      expect(list).to be_a(WhatsrbCloud::Objects::List)
      expect(list.data.size).to eq(2)
      expect(list.data.first).to be_a(WhatsrbCloud::Objects::Template)
      expect(list.data.first.name).to eq('hello')
    end

    it 'supports status and category filters' do
      stub = stub_request(:get, "#{FakeServer::BASE}/business_accounts/ba_abc/templates?status=approved&category=utility")
             .to_return(status: 200,
                        body: '{"data":[{"id":"tpl_1","name":"hello","status":"approved"}],"meta":{"total":1}}',
                        headers: FakeServer.json_headers)

      list = templates.list(status: 'approved', category: 'utility')
      expect(list.data.size).to eq(1)
      expect(stub).to have_been_requested
    end
  end

  describe '#retrieve' do
    it 'returns a Template object' do
      FakeServer.stub_get('/business_accounts/ba_abc/templates/tpl_1', response: {
                            'data' => {
                              'id' => 'tpl_1', 'name' => 'hello', 'status' => 'approved',
                              'category' => 'utility', 'language' => 'en',
                              'components' => { 'BODY' => { 'text' => 'Hello {{1}}' } }
                            }
                          })

      tpl = templates.retrieve('tpl_1')
      expect(tpl.id).to eq('tpl_1')
      expect(tpl.name).to eq('hello')
      expect(tpl).to be_approved
    end
  end

  describe '#create' do
    it 'creates a template with envelope' do
      stub = stub_request(:post, "#{FakeServer::BASE}/business_accounts/ba_abc/templates")
             .with(body: '{"template":{"name":"order_confirm","category":"utility","language":"en"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"tpl_new","name":"order_confirm","status":"pending"}}',
                        headers: FakeServer.json_headers)

      tpl = templates.create(name: 'order_confirm', category: 'utility', language: 'en')
      expect(tpl).to be_a(WhatsrbCloud::Objects::Template)
      expect(tpl.id).to eq('tpl_new')
      expect(stub).to have_been_requested
    end
  end

  describe '#delete' do
    it 'deletes a template and returns true' do
      FakeServer.stub_delete('/business_accounts/ba_abc/templates/tpl_1')

      result = templates.delete('tpl_1')
      expect(result).to be true
    end
  end

  describe '#sync' do
    it 'syncs templates and returns a List' do
      FakeServer.stub_post('/business_accounts/ba_abc/templates/sync', response: {
                             'data' => [
                               { 'id' => 'tpl_1', 'name' => 'hello', 'status' => 'approved' }
                             ],
                             'meta' => { 'total' => 1 }
                           })

      list = templates.sync
      expect(list).to be_a(WhatsrbCloud::Objects::List)
      expect(list.data.size).to eq(1)
    end
  end

  describe '#clone' do
    it 'clones a template and returns the copy' do
      FakeServer.stub_post('/business_accounts/ba_abc/templates/tpl_1/clone', response: {
                             'data' => { 'id' => 'tpl_copy', 'name' => 'hello_copy', 'status' => 'draft' }
                           }, status: 201)

      tpl = templates.clone('tpl_1')
      expect(tpl).to be_a(WhatsrbCloud::Objects::Template)
      expect(tpl.name).to eq('hello_copy')
    end
  end

  describe '#send_test' do
    it 'sends a test message and returns a Message' do
      stub = stub_request(:post, "#{FakeServer::BASE}/business_accounts/ba_abc/templates/tpl_1/send_test")
             .with(body: '{"to":"+33600000001"}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_test","message_type":"template","to":"+33600000001"}}',
                        headers: FakeServer.json_headers)

      msg = templates.send_test('tpl_1', to: '+33600000001')
      expect(msg).to be_a(WhatsrbCloud::Objects::Message)
      expect(msg.id).to eq('msg_test')
      expect(stub).to have_been_requested
    end

    it 'includes variables when provided' do
      stub = stub_request(:post, "#{FakeServer::BASE}/business_accounts/ba_abc/templates/tpl_1/send_test")
             .with(body: '{"to":"+33600000001","variables":["John","ORD-123"]}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_test2","message_type":"template"}}',
                        headers: FakeServer.json_headers)

      templates.send_test('tpl_1', to: '+33600000001', variables: %w[John ORD-123])
      expect(stub).to have_been_requested
    end
  end
end
