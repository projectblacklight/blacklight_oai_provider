require 'blacklight'
require 'blacklight_oai_provider'
require 'rails'

module BlacklightOaiProvider
  class Engine < Rails::Engine
  
    # Do these things in a to_prepare block, to try and make them work
    # in development mode with class-reloading. The trick is we can't
    # be sure if the controllers we're modifying are being reloaded in
    # dev mode, if they are in the BL plugin and haven't been copied to
    # local, they won't be. But we do our best. 
    config.to_prepare do
      BlacklightOaiProvider.inject!
    end
  end
end
