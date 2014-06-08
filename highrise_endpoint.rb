Bundler.require(:default)
require "endpoint_base/sinatra/base"
Dotenv.load

module HighriseEndpoint
  class Application < EndpointBase::Sinatra::Base
    set :logging, true

    Highrise::Base.site = ENV["HIGHRISE_SITE_URL"].blank? ? "http://www.example.com" : ENV["HIGHRISE_SITE_URL"]
    Highrise::Base.user = ENV["HIGHRISE_API_TOKEN"].blank? ? "thisIsAFakeKey123" : ENV["HIGHRISE_API_TOKEN"]

    # Adds new customer to Highrise from spree hub.
    post "/add_customer" do
      people = Highrise::Person.search(customer_id: @payload[:customer][:id])

      if people.length > 0
        @person = people.first
        structure = HighriseEndpoint::PersonBlueprint.new(payload: @payload, person: JSON.parse(@person.to_json)).build

        if @person.field("Customer ID") == @payload[:customer][:id]
          @person.load(structure)
        else
          @person = Highrise::Person.new(structure)
        end

        if @person.save
          jbuilder :update_customer_success
        else
          jbuilder :update_customer_failure
        end
      else
        structure = HighriseEndpoint::PersonBlueprint.new(payload: @payload).build
        @person = Highrise::Person.new(structure)

        if @person.save
          jbuilder :add_customer_success
        else
          jbuilder :add_customer_failure
        end
      end
    end

    post "/update_customer" do
      people = Highrise::Person.search(customer_id: @payload[:customer][:id])
      if people.length > 0
        @person = people.first
        structure = HighriseEndpoint::PersonBlueprint.new(payload: @payload, person: JSON.parse(@person.to_json)).build

        if @person.field("Customer ID") == @payload[:customer][:id]
          @person.load(structure)
        else
          @person = Highrise::Person.new(structure)
        end

        if @person.save
          jbuilder :update_customer_success
        else
          jbuilder :update_customer_failure
        end
      else
        structure = HighriseEndpoint::PersonBlueprint.new(payload: @payload).build
        @person = Highrise::Person.new(structure)

        if @person.save
          jbuilder :add_customer_success
        else
          jbuilder :add_customer_failure
        end
      end
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
end
