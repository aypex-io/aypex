module Aypex
  module DataFeeds
    module Google
      class OptionalAttributes
        prepend Aypex::ServiceModule::Base

        def call(input)
          information = {}

          input[:product].property_ids.each do |key|
            name = Aypex::Property.find(key)&.name
            value = input[:product].property(name)
            unless value.nil?
              information[name] = value
            end
          end

          success(information: information)
        end
      end
    end
  end
end
