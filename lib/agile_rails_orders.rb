require 'agile_rails_orders/version'
require 'agile_rails_orders/engine'

###############################################################################
# Demonstration of external application added as a rails plugin gem.
###############################################################################
module AgileRailsOrders

def self.routes
  Rails.application.routes.draw do
    # Orders specific routes
  end
end

###############################################################################
# AgileRailsOrders specific assets
###############################################################################
def self.assets
  Dir[File.expand_path('../../app/assets/images/*', __FILE__)]
end

end

Agile.add_forms_path File.expand_path('../../app/forms', __FILE__)
Agile.add_forms_path File.expand_path('../../app/reports/forms', __FILE__)
