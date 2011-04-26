require 'blacklight_oai_provider'

# We do our injection in to_prepare so an app can stop it or configure
# it in an initializer, using BlacklightOaiProvider.omit_inject .
# Only weirdness about this is our CSS will always be last, so if an app
# wants to over-ride it, might want to set BlacklightOaiProvider.omit_inject => {:css => true}
config.to_prepare do 
  BlacklightOaiProvider.inject!
end
