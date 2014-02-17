module Hobo
    class Metadata
    class << self
      attr_accessor :metadata, :store, :defaults

      def store
        @store ||= {}
      end

      def metadata
        @metadata ||= {}
      end

      def default type, value
        @defaults ||= {}
        @defaults[type] = value
        store[type] = value if store[type].nil?
      end

      def add task, type, data = nil
        data = store[type] if data.nil?
        metadata[task] ||= {}
        metadata[task][type] = data
      end

      def reset_store
        @store = {}
        @defaults.each do |k, v|
          @store[k] = v.nil? ? nil : v.dup
        end
      end
    end
  end
end