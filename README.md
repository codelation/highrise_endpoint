##Overview
This integration is designed to integrate spree hub with Highrise CRM. All transactions related to the spree storefront will be available for view in Highrise. This is a one-way integration. Data on Highrise will not sync back to the storefront.

## Running Locally
Start server locally with

```bash
$ rake start RACK_ENV=environment
```

## Testing
Run tests with

```bash
$ rake test
```

## Installed Gems

### Production/Development/Test

- [Awesome Print](https://github.com/michaeldv/awesome_print)
- [Endpoint::Base](https://github.com/spree/endpoint_base)
- [Foreman](https://github.com/ddollar/foreman)
- [Puma](http://puma.io)
- [Rake](https://github.com/jimweirich/rake)
- [Sinatra](http://www.sinatrarb.com)
- [Tilt](https://github.com/rtomayko/tilt/tree/tilt-1)
- [Tilt::JBuilder](https://github.com/anthonator/tilt-jbuilder)


### Test
- [Faker](https://github.com/stympy/faker)
- [Capybara](https://github.com/jnicklas/capybara)
- [database_cleaner](https://github.com/bmabey/database_cleaner)
- [Faker](https://github.com/stympy/faker)
- [Guard](https://github.com/guard/guard)
- [guard-rspec](https://github.com/guard/guard-rspec)
- [rack-test](https://github.com/brynary/rack-test)
- [rb-fsevent](https://github.com/thibaudgg/rb-fsevent)
- [Rspec](http://rspec.info)
- [terminal-notifier-guard](https://github.com/Springest/terminal-notifier-guard)
- [vcr](https://github.com/vcr/vcr)
- [webmock](https://github.com/bblimke/webmock)

## Webhooks

| Name | Value | Example |
| :----| :-----| :------ |
| add_customer | Inventory Account (required) | Inventory Asset |
| update_customer | Cost of Goods Sold Account | Cost Of Goods Sold |
| add_order | Income Account | Sales of Product Income |
| update_order | Track inventory | false |
| add_product | Track inventory | false |
| update_product | Track inventory | false |
| add_shipment | Track inventory | false |
| update_shipment | Track inventory | false |
