# This is a monkey patch to allow Highrise to not give a 422 about having party/parties nested.
module Highrise
  class Deal
    def encode_with_nested_attribute_exclusion(options={})
      encode_without_nested_attribute_exclusion({:except => [:party, :parties]}.merge(options))
    end
    alias_method_chain :encode, :nested_attribute_exclusion
  end
end

module HighriseEndpoint
  class DealBlueprint < Blueprint
    # A deal hash structure, if provided the blueprint hash structure will only include what has changed
    attr_accessor :deal

    def initialize(payload: nil, deal: nil)
      super(payload: payload)
      @deal = deal.with_indifferent_access if deal
    end

    def attributes
      order = @payload[:order]
      person = Highrise::Person.search(email: order[:email]).first

      {
        currency: order[:currency],
        name:     "Order ##{order[:id]}",
        price:    order[:totals][:order]/100.00,
        status:   "won",
        party_id: person ? person.id : nil
      }.with_indifferent_access
    end

    # Only return the part of the hash that has changed attributes
    def build
      if @deal
        attributes - @deal
      else
        attributes
      end
    end
  end
end
