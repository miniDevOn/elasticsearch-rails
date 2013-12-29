module Elasticsearch
  module Model
    module Response

      # Encapsulates the collection of records returned from the database
      #
      # Implements Enumerable and forwards its methods to the {#records} object,
      # which is provided by an {Elasticsearch::Model::Adapter::Adapter} implementation.
      #
      class Records
        include Enumerable

        extend  Support::Forwardable
        forward :records, :each, :empty?, :size, :slice, :[], :to_a, :to_ary

        include Base

        # @see Base#initialize
        #
        def initialize(klass, response, results=nil, response_object=nil)
          super
          @response = response
          @results  = results
          @ids = response['hits']['hits'].map { |hit| hit['_id'] }

          # Include module provided by the adapter in the singleton class ("metaclass")
          #
          adapter = Adapter.from_class(klass)
          metaclass = class << self; self; end
          metaclass.__send__ :include, adapter.records_mixin

          self
        end

        # Yields [record, hit] pairs to the block
        #
        def each_with_hit(&block)
          records.zip(@results).each(&block)
        end

        # Yields [record, hit] pairs and returns the result
        #
        def map_with_hit(&block)
          records.zip(@results).map(&block)
        end

        # Delegate methods to `@records`
        #
        def method_missing(method_name, *arguments)
          records.respond_to?(method_name) ? records.__send__(method_name, *arguments) : super
        end

        # Respond to methods from `@records`
        #
        def respond_to?(method_name, include_private = false)
          records.respond_to?(method_name) || super
        end

      end
    end
  end
end
