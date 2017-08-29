# BlacklightOaiProvider: OAI-PMH service endpoint for Blacklight applications

## Description

The BlacklightOaiProvider plugin provides an [Open Archives Initiative Protocolo for Metadata Harvesting (OAI-PMH)](http://www.openarchives.org/pmh/) data provider endpoint, using the [ruby-oai gem](https://github.com/code4lib/ruby-oai), that let service providers harvest that metadata.

## Requirements

A Rails app using Blacklight 3.x.

OAI-PMH requires a timestamp field for all records, so your Solr index should include an appropriate field. By default, the name of this field is simply `timestamp`.

## Installation

Add
```ruby
    gem "blacklight_oai_provider"
```

to your Gemfile and run `bundle install`.

Then run `rails generate blacklight_oai_provider` to install the appropriate extensions into your `CatalogController` and `SolrDocument` classes. If you want to do customize the way this installs, instead you may:

- add this to your Solr Document model:
```ruby
    use_extension(BlacklightOaiProvider::SolrDocumentExtension)
```
- add this to your Controller:
```ruby
    include BlacklightOaiProvider::ControllerExtension
```

## Configuration

While the plugin provides some sensible (albeit generic) defaults out of the box, you probably will want to customize the OAI provider configuration.

### For Blacklight 3.x.x

You can provide OAI-PMH provider parameters by placing the following in your blacklight configuration, in `./config/initializers/blacklight_config.rb`

```ruby
  config[:oai] = {
    :provider => {
      :repository_name => 'Test',
      :repository_url => 'http://localhost',
      :record_prefix => '',
      :admin_email => 'root@localhost'
    },
    :document => {
      :timestamp => 'timestamp',
      :limit => 25
    }
  }
```
### For Blacklight 4.x.x

in `app/controllers/catalog_controller.rb`

```ruby
  configure_blacklight do |config|

    # ...

    config.oai = {
      :provider => {
        :repository_name => 'Test',
        :repository_url => 'http://localhost',
        :record_prefix => '',
        :admin_email => 'root@localhost'
      },
      :document => {
        :timestamp => 'timestamp',
        :limit => 25
      }
    }

    # ...

  end
```
The "provider" configuration is documented as part of the ruby-oai gem at http://oai.rubyforge.org/

### Injection

This plugin assumes it is in a Blacklight Rails app, uses Blacklight methods, Rails methods, and standard ruby module includes to inject it's behaviors into the app.  

You can turn off this injection if you like, although it will make the plugin less (or non-) functional unless you manually do similar injection. See lib/blacklight_oai_provider.rb#inject! to see exactly what's going on.

In any initializer, you can set:
```ruby
  BlacklightOaiProvider.omit_inject = true
```
to turn off all injection. The plugin will be completely non-functional if you do this, of course. But perhaps you could try to re-use some of it's classes in a non-Blacklight, highly hacked Blacklight, or even non-Rails application this way.

You can also turn off injection of individual components, which could be more useful:
```ruby
  BlacklightOaiProvider.omit_inject = {
    :routes => false,
  }
```
## Tests

There are some basic tests. You can test OAI-PMH conformance against http://www.openarchives.org/data/registerasprovider.html#Protocol_Conformance_Testing or browse the data at http://re.cs.uct.ac.za/
