# frozen_string_literal: true

module WhatsrbCloud
  module Objects
    class Template
      attr_reader :id, :meta_template_id, :name, :category, :status, :language,
                  :header_type, :components, :variable_examples, :rejection_reason

      def initialize(data)
        @id                 = data['id']
        @meta_template_id   = data['meta_template_id']
        @name               = data['name']
        @category           = data['category']
        @status             = data['status']
        @language           = data['language']
        @header_type        = data['header_type']
        @components         = data['components']
        @variable_examples  = data['variable_examples']
        @rejection_reason   = data['rejection_reason']
      end

      def approved?
        @status == 'approved'
      end

      def rejected?
        @status == 'rejected'
      end

      def pending?
        @status == 'pending'
      end

      def to_h
        {
          'id' => @id, 'name' => @name, 'category' => @category,
          'status' => @status, 'language' => @language
        }
      end
    end
  end
end
