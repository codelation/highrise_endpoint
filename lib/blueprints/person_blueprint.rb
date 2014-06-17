module HighriseEndpoint
  # Maps a request payload into a highrise hash structure
  class PersonBlueprint < Blueprint
    # A person hash structure, if provided the blueprint hash structure will only include what has changed
    attr_accessor :person

    def initialize(payload: nil, person: nil)
      super(payload: payload)
      @person = person.with_indifferent_access if person
    end

    def attributes
      customer        = @payload[:customer]
      billing_address = customer[:billing_address]

      {
        first_name: customer[:firstname],
        last_name:  customer[:lastname],
        contact_data: {
          email_addresses: [
            {
              address: customer[:email],
              location: 'Work'
            }
          ],
          addresses: [
            {
              # Need to figure out what all of the information is to be added in the address
              city:     billing_address[:city],
              country:  billing_address[:country],
              location: 'Work',
              state:    billing_address[:state],
              street:   billing_address[:address1],
              zip:      billing_address[:zipcode]
            }
          ],
          phone_numbers: [
            {
              location: 'Work',
              number:   billing_address[:phone]
            }
          ],
          customer_id: customer[:id]
        }
      }.with_indifferent_access
    end

    # Only return the part of the hash that has changed attributes
    def build
      if @person
        attributes - @person
      else
        attributes
      end
    end
  end
end
