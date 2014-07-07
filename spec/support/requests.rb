module HighriseEndpoint
  # This class could probably be refactored... But it includes faked requests with random data to keep Highrise happy.
  class Requests
    # The type refers to the type of request from the hub, data is what is generated
    attr_accessor :type, :data

    def initialize(type, name = nil)
      @type = type

      # Load from path if the file exists. This way the data will match the VCR cassettes
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

    # This function should be refactored.
    def to_hash
      @data ||= case @type
        when :address
          {
            request_id: Faker::Number.number(25),
            address: {
              firstname: Faker::Name.first_name,
              lastname:  Faker::Name.last_name,
              address1:  Faker::Address.street_address,
              address2:  Faker::Address.secondary_address,
              zipcode:   Faker::Address.zip_code,
              city:      Faker::Address.city,
              state:     Faker::Address.state,
              country:   Faker::Address.country,
              phone:     Faker::Number.number(25)
            },
            parameters: {
              "highrise.api_token" => "thisIsAFakeKey123",
              "highrise.site_url" =>  "http://www.example.com"
            }
          }
        when :customer
          shipping_address    = HighriseEndpoint::Requests.new(:address, "shipping").to_hash[:address]
          billing_address     = HighriseEndpoint::Requests.new(:address, "billing").to_hash[:address]
          person_tags         = [Faker::Commerce.product_name, Faker::Commerce.product_name]
          me                  = Highrise::User.me.id

          {
            request_id: Faker::Number.number(25),
            customer: {
              id:        Faker::Number.number(10),
              firstname: billing_address[:firstname],
              lastname:  billing_address[:lastname],
              email:     Faker::Internet.email,
              shipping_address: shipping_address,
              billing_address: billing_address,
              highrise_tags: {
                person: person_tags
              },
              highrise_tasks: {
                person: [
                  {
                    body: Faker::Lorem.sentence,
                    due: "today",
                    assigned_to: me
                  },
                  {
                    body: Faker::Lorem.sentence,
                    due: "tomorrow",
                    assigned_to: me
                  },
                  {
                    body: Faker::Lorem.sentence,
                    due: "this_week",
                    assigned_to: me
                  },
                  {
                    body: Faker::Lorem.sentence,
                    due: "next_week",
                    assigned_to: me
                  },
                  {
                    body: Faker::Lorem.sentence,
                    due: "later",
                    assigned_to: me
                  },
                  {
                    body: Faker::Lorem.sentence,
                    due: "2007-03-10T15:11:52Z",
                    assigned_to: me
                  }
                ]
              },
            },
            parameters: {
              "highrise.api_token" => "thisIsAFakeKey123",
              "highrise.site_url" =>  "http://www.example.com"
            }
          }
        when :order
          shipping_address    = HighriseEndpoint::Requests.new(:address, "shipping").to_hash[:address]
          billing_address     = HighriseEndpoint::Requests.new(:address, "billing").to_hash[:address]
          product             = HighriseEndpoint::Requests.new(:product).to_hash[:product]
          customer            = HighriseEndpoint::Requests.new(:customer, "existing_add").to_hash[:customer]

          quantity = Faker::Number.digit
          order_subtotal = product[:price] * quantity.to_i
          order_tax = order_subtotal.to_i * 0.65
          order_shipping = Faker::Number.digit.to_i
          order_total = order_subtotal + order_tax + order_shipping
          deal_tags = [Faker::Commerce.product_name, Faker::Commerce.product_name]
          me = Highrise::User.me.id

          {
            request_id: Faker::Number.number(25),
            order: {
              id: Faker::Number.number(10),
              status: [:complete, :in_progress, :pending].sample,
              channel: :spree,
              email: customer[:email],
              currency: "USD",
              placed_on: Time.now,
              totals: {
                item: order_subtotal,
                adjustment: order_shipping,
                tax: order_tax,
                shipping: order_shipping,
                payment: order_total,
                order: order_total
              },
              line_items: [
                {
                  product_id: product[:id],
                  name: product[:name],
                  quantity: quantity,
                  price: product[:price]
                },
                {
                  product_id: product[:id],
                  name: product[:name],
                  quantity: quantity,
                  price: product[:price]
                }
              ],
              highrise_tags: {
                deal: deal_tags,
                person: deal_tags
              },
              highrise_tasks: {
                person: [
                  {
                    body: Faker::Lorem.sentence,
                    due: "tomorrow",
                    assigned_to: me
                  },
                  {
                    body: Faker::Lorem.sentence,
                    due: "next_week",
                    assigned_to: me
                  },
                  {
                    body: Faker::Lorem.sentence,
                    due: "2007-03-10T15:11:52Z",
                    assigned_to: me
                  }
                ],
                deal: [
                  {
                    body: Faker::Lorem.sentence,
                    due: "today",
                    assigned_to: me
                  },
                  {
                    body: Faker::Lorem.sentence,
                    due: "this_week",
                    assigned_to: me
                  },
                  {
                    body: Faker::Lorem.sentence,
                    due: "later",
                    assigned_to: me
                  }
                ]
              },
              adjustments: [
                {
                  name: "Tax",
                  value: order_tax
                },
                {
                  name: "Shipping",
                  value: order_shipping
                }
              ],
              shipping_address: shipping_address,
              billing_address: billing_address,
              payments: [
                {
                  number: 63,
                  status: [:complete, :in_progress, :pending, :failed].sample,
                  amount: order_total,
                  payment_method: "Credit Card"
                }
              ]
            },
            parameters: {
              "highrise.api_token" => "thisIsAFakeKey123",
              "highrise.site_url" =>  "http://www.example.com"
            }
          }
        when :product
          product_name = Faker::Commerce.product_name
          product_id   = product_name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
          product_price = Faker::Number.number(4).to_i
          cost_price    = rand(1 .. product_price)

          {
            request_id: Faker::Number.number(25),
            product: {
              id: product_id,
              name: product_name,
              sku: product_id,
              description: Faker::Lorem.sentence,
              price: product_price,
              cost_price: cost_price,
              available_on: Time.now,
              permalink: product_id,
              meta_description: nil,
              meta_keywords: nil,
              shipping_category: "Default",
              taxons: [
                [
                  "Categories",
                  "Clothes",
                  "T-Shirts"
                ],
                [
                  "Brands",
                  "Spree"
                ],
                [
                  "Brands",
                  "Open Source"
                ]
              ],
              options: [
                "color",
                "size"
              ],
              properties: {
                material: "cotton",
                fit: "smart fit"
              },
              images: [
                {
                  url: "http://dummyimage.com/600x400/000/fff.jpg&text=#{product_name}",
                  position: 1,
                  title: product_name,
                  type: "thumbnail",
                  dimensions: {
                    height: 220,
                    width: 100
                  }
                }
              ],
              variants: [
                {
                  sku: "#{product_id}-Super-Special-Edition",
                  price: product_price + 5,
                  cost_price: product_price + 5,
                  quantity: Faker::Number.number(25),
                  options: {
                    color: "GREY",
                    size: "S"
                  },
                  images: [
                    {
                      url: "http://dummyimage.com/600x400/000/fff.jpg&text=#{product_name} Super Special Edition",
                      position: 1,
                      title: "#{product_name} Super Special Edition",
                      type: "thumbnail",
                      dimensions: {
                        height: 220,
                        width: 100
                      }
                    }
                  ]
                }
              ]
            },
            parameters: {
              "highrise.api_token" => "thisIsAFakeKey123",
              "highrise.site_url" =>  "http://www.example.com"
            }
          }
        when :shipment
          order = HighriseEndpoint::Requests.new(:order, "for_shipment").to_hash[:order]
          me    = Highrise::User.me.id

          {
            request_id: Faker::Number.number(25),
            shipment: {
              id: Faker::Number.number(10),
              order_id: order[:id],
              email: order[:email],
              cost: order[:totals][:shipping],
              status: :ready,
              stock_location: :default,
              shipping_method: "UPS Ground (USD)",
              tracking: Faker::Number.number(25),
              shipped_at: Time.now,
              shipping_address: order[:shipping_address],
              items: order[:line_items],
              highrise_tasks: {
                person: [
                  {
                    body: Faker::Lorem.sentence,
                    due: "tomorrow",
                    assigned_to: me
                  },
                  {
                    body: Faker::Lorem.sentence,
                    due: "next_week",
                    assigned_to: me
                  },
                  {
                    body: Faker::Lorem.sentence,
                    due: "2007-03-10T15:11:52Z",
                    assigned_to: me
                  }
                ],
                deal: [
                  {
                    body: Faker::Lorem.sentence,
                    due: "today",
                    assigned_to: me
                  },
                  {
                    body: Faker::Lorem.sentence,
                    due: "this_week",
                    assigned_to: me
                  },
                  {
                    body: Faker::Lorem.sentence,
                    due: "later",
                    assigned_to: me
                  }
                ]
              },
            },
            parameters: {
              "highrise.api_token" => "thisIsAFakeKey123",
              "highrise.site_url" =>  "http://www.example.com"
            }
          }
      end.with_indifferent_access
    end
  end
end
