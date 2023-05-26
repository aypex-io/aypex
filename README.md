[![CI Tests](https://github.com/aypex-io/aypex/actions/workflows/ci.yml/badge.svg)](https://github.com/aypex-io/aypex/actions/workflows/ci.yml)
[![Standard Ruby Format](https://github.com/aypex-io/aypex/actions/workflows/standard_rb.yml/badge.svg)](https://github.com/aypex-io/aypex/actions/workflows/standard_rb_core.yml)
[![SNYK Gem Dependency](https://github.com/aypex-io/aypex/actions/workflows/snyk.yml/badge.svg)](https://github.com/aypex-io/aypex/actions/workflows/snyk.yml)

## Aypex eCommerce Kit

**Aypex** is an open source e-commerce platform built using Ruby on Rails, intentionally designed to be
plug-able allowing you to build the platform you need, and leave out the stuff you don't.

The benefits of a plug-able e-commerce kit are that it allows you can use customize your setup to your requirements
you can choose form any custom UI: Checkout, Storefront, Admin combination, you can pick your own Email pack, choose your API version or build your own custom set from scratch.

Below are some example setups.
### Headless

```ruby
gem "aypex"

gem "aypex-api"
gem "aypex-emails"
gem "aypex-auth_devise"
```

### Full Rails Stack
```ruby
gem "aypex"

gem "aypex-admin"
gem "aypex-api"
gem "aypex-auth_devise"
gem "aypex-checkout"
gem "aypex-emails"
gem "aypex-storefront"
```

## Documentation

Create a new rails app (Rails >=7.0 using Propshaft)
```bash
rails new [app_name] --database=postgresql -a propshaft
```

Add this line to your application's Gemfile:
```ruby
gem "aypex"
```

And then execute:
```bash
bundle
```

And then run the Aypex install command:
```bash
bin/rails g aypex:install --user_class=Aypex::User
```

## Testing

```bash
bundle exec rake test_app
```

```bash
bundle exec rspec spec
```

## Creating Extensions

To keep Aypex as close to the Rails framework as possible Aypex extensions are just mountable Rails Engines, run the following Rails Plugin command,
using the correct naming conventions to generate the mountable engine type you require.

For `Aypex::Shipping`
```bash
rails plugin new aypex-shipping --mountable
```

For `AypexShipping`
```bash
rails plugin new aypex_shipping --mountable
```

## License

Aypex is released under the [New MIT License](https://github.com/aypex-io/aypex/blob/main/MIT-LICENSE).
