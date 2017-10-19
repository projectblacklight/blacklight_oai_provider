# BlacklightOaiProvider
OAI-PMH service endpoint for Blacklight applications

## Description
The BlacklightOaiProvider plugin provides an [Open Archives Initiative Protocol for Metadata Harvesting (OAI-PMH)](http://www.openarchives.org/pmh/) data provider endpoint, using the [ruby-oai gem](https://github.com/code4lib/ruby-oai), that let service providers harvest that metadata.

### Versioning
Starting `v4.1` major plugin versions are synced with major Blacklight versions. The last known version to work with Blacklight 3.x/Rails 3.x is `v0.1.0`.

A few maintenance branches have been left in place in case there is interest to add support for older versions of rails/blacklight:

`v3.x` -> Support for Blacklight 3.0

`v4.x` -> Support for Blacklight 4.0 and Rails 3.0

## Requirements
A Rails app running Blacklight 4.x and Rails 4.x.

OAI-PMH requires a timestamp field for all records, so your Solr index should include an appropriate field. This field should be able to support date range queries. By default, the name of this field is `timestamp` (more on how to configure this below).

A properly configured documentHandler in the blacklight/solr configuration.

## Installation

Add

```ruby
    gem 'blacklight_oai_provider', '~> 4.1'
```

to your Gemfile and run `bundle install`.

Then run
```ruby
rails generate blacklight_oai_provider:install
```
to install the appropriate extensions into your `CatalogController` and `SolrDocument` classes. If you want to do customize the way this installs, instead you may:

- add this to your Solr Document model:
```ruby
    include BlacklightOaiProvider::SolrDocument
```
- add this to your Controller:
```ruby
    include BlacklightOaiProvider::Controller
```

## Configuration

While the plugin provides some sensible (albeit generic) defaults out of the box, you probably will want to customize the OAI provider configuration.

### Blacklight configuration
You can provide OAI-PMH provider parameters by placing the following in your blacklight configuration (most likely in `app/controllers/catalog_controller.rb`)

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
        :model => SolrDocument, # SolrDocument class you are using.
        :limit => 25
      }
    }

    # ...

  end
```

The "provider" configuration is documented as part of the ruby-oai gem at http://oai.rubyforge.org/

_Note:_ The document handler in your blacklight controller must be configured properly for this plugin to correctly look up records.

### SolrDocument configuration
To change the name of the timestamp solr field in your `SolrDocument` model change the following attribute:
```ruby
    self.timestamp_key = 'record_creation_date' # Default: 'timestamp'
```

The metadata displayed in the xml serialization of each record is based off the `field_semantics` hash in the `SolrDocument`. To update/change these fields add something like the following to your model:

```ruby
  field_semantics.merge!(
    creator: "author_display",
    date: "pub_date",
    subject: "subject_topic_facet",
    title: "title_display",
    language: "language_facet",
    format: "format"
  )
```

The fields used by the dublin core serialization are:
```ruby
  [:contributor, :coverage, :creator, :date, :description, :format, :identifier, :language, :publisher, :relation, :rights, :source, :subject, :title, :type]
```

## Injection
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
We use `engine_cart` and `solr_wrapper` to run tests on a dummy instance of an app using this plugin.

To run the entire test suite:
```ruby
  rake ci
```

You can test OAI-PMH conformance against http://www.openarchives.org/data/registerasprovider.html#Protocol_Conformance_Testing or browse the data at http://re.cs.uct.ac.za/
