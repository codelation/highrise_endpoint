module HighriseEndpoint
  class Requests
    attr_accessor :type, :data

    def initialize(type, name = nil)
      @type = type

      path = File.expand_path("../requests/#{@type.to_s}_#{name ? name : "default"}.yml", __FILE__)
      if File.file?(path)
        @data = YAML::load_file(path)
      else
        self.to_hash
        File.open(path, "w") { |f| f.write @data.to_yaml }
      end
    end

    def [](key)
      self.to_hash.fetch(key)
    end

    def to_json
      self.to_hash.to_json
    end

    def to_hash
      @data ||= case @type
        when :customer
          {
            request_id: Faker::Number.number(25),
            customer: {
              id:        Faker::Number.number(10),
              firstname: Faker::Name.first_name,
              lastname:  Faker::Name.last_name,
              email:     Faker::Internet.email,
              shipping_address: {
                address1: Faker::Address.street_address,
                address2: Faker::Address.secondary_address,
                zipcode:  Faker::Address.zip_code,
                city:     Faker::Address.city,
                state:    Faker::Address.state,
                country:  Faker::Address.country,
                phone:    Faker::Number.number(25)
              },
              billing_address: {
                address1: Faker::Address.street_address,
                address2: Faker::Address.secondary_address,
                zipcode:  Faker::Address.zip_code,
                city:     Faker::Address.city,
                state:    Faker::Address.state,
                country:  Faker::Address.country,
                phone:    Faker::Number.number(25)
              }
            }
          }
      end.with_indifferent_access
    end
  end
end
