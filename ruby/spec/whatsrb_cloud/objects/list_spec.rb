# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Objects::List do
  let(:items) { [double(name: 'A'), double(name: 'B'), double(name: 'C')] }
  let(:list) { described_class.new(data: items, meta: { 'total' => 3 }) }

  describe 'Enumerable' do
    it 'includes Enumerable' do
      expect(described_class).to include(Enumerable)
    end

    it '#each yields each item' do
      names = []
      list.each { |item| names << item.name }
      expect(names).to eq(%w[A B C])
    end

    it '#map works' do
      expect(list.map(&:name)).to eq(%w[A B C])
    end

    it '#first returns the first element' do
      expect(list.first.name).to eq('A')
    end

    it '#select works' do
      expect(list.select { |i| i.name == 'B' }.size).to eq(1)
    end
  end

  describe '#size' do
    it 'returns the number of items' do
      expect(list.size).to eq(3)
    end
  end

  describe '#length' do
    it 'is an alias for size' do
      expect(list.length).to eq(list.size)
    end
  end

  describe '#empty?' do
    it 'returns false when data is present' do
      expect(list).not_to be_empty
    end

    it 'returns true when data is empty' do
      empty_list = described_class.new(data: [], meta: {})
      expect(empty_list).to be_empty
    end
  end

  describe '#data' do
    it 'still exposes the raw array' do
      expect(list.data).to eq(items)
    end
  end
end
