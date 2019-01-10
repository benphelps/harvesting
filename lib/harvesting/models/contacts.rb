module Harvesting
  module Models
    class Contacts < Base
      include Harvesting::Enumerable
      extend Forwardable

      attributed :per_page,
                 :total_pages,
                 :total_entries,
                 :next_page,
                 :previous_page,
                 :page,
                 :links

      attr_reader :entries

      def initialize(attrs, opts = {})
        super(attrs.reject {|k,v| k == "contacts" }, opts)
        @api_page = attrs
        @entries = attrs["contacts"].map do |entry|
          Contact.new(entry, client: opts[:client])
        end
      end

      def page
        @attributes['page']
      end

      def size
        total_entries
      end

      def fetch_next_page
        new_page = page + 1
        @entries += @client.contacts(page: new_page).entries
        @attributes['page'] = new_page
      end
    end
  end
end
