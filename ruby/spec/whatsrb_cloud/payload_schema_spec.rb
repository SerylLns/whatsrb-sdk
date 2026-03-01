# frozen_string_literal: true

RSpec.describe WhatsrbCloud::PayloadSchema do
  let(:raw_schema) do
    [
      { "name" => "room_number", "field_type" => "text", "required" => true },
      { "name" => "description", "field_type" => "text", "required" => true },
      { "name" => "due_at", "field_type" => "datetime", "required" => false },
      { "name" => "priority", "field_type" => "text", "required" => false }
    ]
  end

  let(:schema) { described_class.new(raw_schema) }

  describe "#fields" do
    it "returns Field structs" do
      expect(schema.fields.size).to eq(4)
      expect(schema.fields.first).to be_a(described_class::Field)
      expect(schema.fields.first.name).to eq("room_number")
      expect(schema.fields.first.field_type).to eq("text")
    end
  end

  describe "#field_names" do
    it "returns all field names as symbols" do
      expect(schema.field_names).to eq(%i[room_number description due_at priority])
    end
  end

  describe "#required" do
    it "returns only required field names" do
      expect(schema.required).to eq(%i[room_number description])
    end
  end

  describe "#each" do
    it "is Enumerable" do
      expect(schema).to be_a(Enumerable)
      expect(schema.map(&:name)).to eq(%w[room_number description due_at priority])
    end
  end

  describe "#empty?" do
    it "returns false when fields exist" do
      expect(schema).not_to be_empty
    end

    it "returns true when no fields" do
      expect(described_class.new([])).to be_empty
    end
  end

  describe "#size" do
    it "returns the number of fields" do
      expect(schema.size).to eq(4)
    end
  end

  describe "#to_a" do
    it "returns the raw array" do
      expect(schema.to_a).to eq(raw_schema)
    end
  end

  describe "with nil input" do
    it "handles nil gracefully" do
      empty = described_class.new(nil)
      expect(empty).to be_empty
      expect(empty.fields).to eq([])
    end
  end

  describe "#check" do
    context "with all required fields present" do
      let(:payload) { { "room_number" => "204", "description" => "Clean room", "priority" => "high" } }
      let(:result) { schema.check(payload) }

      it "is valid" do
        expect(result).to be_valid
      end

      it "has no missing fields" do
        expect(result.missing).to be_empty
      end

      it "lists present fields" do
        expect(result.present).to eq(%i[room_number description priority])
      end

      it "returns a hash with all fields" do
        expect(result.to_h).to eq({
          room_number: "204",
          description: "Clean room",
          due_at: nil,
          priority: "high"
        })
      end
    end

    context "with missing required fields" do
      let(:payload) { { "room_number" => "204" } }
      let(:result) { schema.check(payload) }

      it "is not valid" do
        expect(result).not_to be_valid
      end

      it "lists missing required fields" do
        expect(result.missing).to eq([:description])
      end

      it "lists present fields" do
        expect(result.present).to eq([:room_number])
      end
    end

    context "with empty string values" do
      let(:payload) { { "room_number" => "204", "description" => "" } }
      let(:result) { schema.check(payload) }

      it "treats empty strings as missing" do
        expect(result).not_to be_valid
        expect(result.missing).to eq([:description])
      end
    end

    context "with symbol keys" do
      let(:payload) { { room_number: "204", description: "Clean room" } }
      let(:result) { schema.check(payload) }

      it "normalizes keys to strings" do
        expect(result).to be_valid
      end
    end

    context "with nil payload" do
      let(:result) { schema.check(nil) }

      it "treats all required fields as missing" do
        expect(result).not_to be_valid
        expect(result.missing).to eq(%i[room_number description])
      end
    end
  end

  describe described_class::Field do
    let(:field) { described_class.new(name: "room_number", field_type: "text", required: true) }

    it "#required? returns true when required" do
      expect(field).to be_required
    end

    it "#required? returns false when not required" do
      optional = described_class.new(name: "priority", field_type: "text", required: false)
      expect(optional).not_to be_required
    end

    it "#to_h returns hash representation" do
      expect(field.to_h).to eq({ "name" => "room_number", "field_type" => "text", "required" => true })
    end
  end
end
