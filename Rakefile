$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

$:.unshift("./lib/")
require './lib/carabiner'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'KeychainExample'

  app.frameworks += ['Security']

  app.entitlements['keychain-access-groups'] = [
    app.seed_id + '.' + app.identifier
  ]
end
