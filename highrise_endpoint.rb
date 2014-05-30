Bundler.require(:default)
require "endpoint_base/sinatra/base"

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

  # deletes recursively
  def deep_reject_key!(key)
    keys.each {|k| delete(k) if k == key || self[k] == self[key] }

    values.each {|v| v.deep_reject_key!(key) if v.is_a? Hash }
    self
  end
end

class HighriseEndpoint < EndpointBase::Sinatra::Base
  set :logging, true

  Highrise::Base.site = ENV["HIGHRISE_SITE_URL"].blank? ? "http://www.example.com" : ENV["HIGHRISE_SITE_URL"]
  Highrise::Base.user = ENV["HIGHRISE_API_TOKEN"].blank? ? "thisIsAFakeKey123" : ENV["HIGHRISE_API_TOKEN"]

  # Payload should always be supplied
  def customer_attribute_hash(payload: nil, person: nil)
    billing_address = payload[:customer][:billing_address]

    attributes = {
      first_name: payload[:customer][:firstname],
      last_name:  payload[:customer][:lastname],
      contact_data: {
        email_addresses: [
          {
            address: payload[:customer][:email],
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
        customer_id: payload[:customer][:id]
      }
    }.with_indifferent_access

    if person
      person = JSON.parse(person.to_json).with_indifferent_access
      attributes = attributes - person
    end

    attributes
  end

  # Adds new customer to Highrise from spree hub.
  post "/add_customer" do
    people = Highrise::Person.search(customer_id: @payload[:customer][:id])
    @person = people.first

    if @person
      if @person.field("Customer ID") == @payload[:customer][:id]
        @person.load(customer_attribute_hash(payload: @payload, person: @person))
      else
        @person = Highrise::Person.new(customer_attribute_hash(payload: @payload))
      end
    else
      @person = Highrise::Person.new(customer_attribute_hash(payload: @payload))
    end

    if @person.save
      jbuilder :add_customer_success
    else
      jbuilder :add_customer_failure
    end
  end

  #checks to see if customer exists.  If does not exist, adds customer.
  # If does exist, updates the necessary data.
  post "/update_customer" do

  end

  post "/add_order" do

  end

  post "/update_order" do

  end

  post "/add_product" do

  end

  post "/update_product" do

  end

  post "/add_shipment" do

  end

  post "/update_shipment" do

  end
end
