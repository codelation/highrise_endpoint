module HighriseEndpoint
  class DealBlueprint < Blueprint
    attr_accessor :deal

    def initialize(payload: nil, deal: nil)
      super(payload: payload)
      @deal = deal.with_indifferent_access if deal
    end

    def attributes
      order = @payload[:order]
      person = Highrise::Person.search(order[:billing_address]).first

      {
        currency: order[:currency],
        name:     order[:id],
        price:    order[:totals][:order]/100.00,
        status:   "won",
        party_id: person.id
      }.with_indifferent_access
    end

    def build
      if @deal
        attributes - @deal
      else
        attributes
      end
    end
  end
end
