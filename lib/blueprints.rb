class Hash
  # Returns a hash that removes any matches with the other hash
  #
  # {a: {b:"c"}} - {:a=>{:b=>"c"}}                   # => {}
  # {a: [{c:"d"},{b:"c"}]} - {:a => [{c:"d"}, {b:"d"}]} # => {:a=>[{:b=>"c"}]}
  #
  def delete_merge!(other_hash)
    other_hash.each_pair do |k,v|
      tv = self[k]
      if tv.is_a?(Hash) && v.is_a?(Hash) && v.present? && tv.present?
        tv.delete_merge!(v)
      elsif v.is_a?(Array) && tv.is_a?(Array) && v.present? && tv.present?
        v.each_with_index do |x, i|
          tv[i].delete_merge!(x)
        end
        self[k] = tv - [{}]
      else
        self.delete(k) if self.has_key?(k) && tv == v
      end
      self.delete(k) if self.has_key?(k) && self[k].blank?
    end
    self
  end

  def delete_merge(other_hash)
    dup.delete_merge!(other_hash)
  end

  def -(other_hash)
    self.delete_merge(other_hash)
  end

  def deep_reject_key!(key)
    keys.each {|k| delete(k) if k == key || self[k] == self[key] }

    values.each {|v| v.deep_reject_key!(key) if v.is_a? Hash }
    self
  end
end

module HighriseEndpoint
  class Blueprint
    attr_accessor :payload

    def initialize(payload: nil)
      @payload = payload
    end
  end

  class PersonBlueprint < Blueprint
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

    def build
      if @person
        attributes - @person
      else
        attributes
      end
    end
  end

  class DealBlueprint < Blueprint
    attr_accessor :deal

    def initialize(payload: nil, deal: nil)
      super(payload: payload)
      @deal = deal.with_indifferent_access if deal
    end

    def attributes
      order = @payload[:order]

      # <deal>
#         <account-id type="integer"></account-id>
#         <author-id type="integer"></author-id>
#         <background></background>
#         <category-id type="integer"></category-id>
#         <created-at type="datetime"></created-at>
#         <currency></currency>
#         <duration type="integer"></duration>
#         <group-id type="integer"></group-id>
#         <name></name>
#         <owner-id type="integer"></owner-id>
#         <party-id type="integer"></party-id>
#         <price type="integer"></price>
#         <price-type></price-type>
#         <responsible-party-id type="integer"></responsible-party-id>
#         <status></status>
#         <status-changed-on type="date"></status-changed-on>
#         <parties type="array">
#           <party>...</party>
#         </parties>
#         <party>...</party>
#       </deal>

      {
        name:   order[:id],
        status: order[:status]
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
