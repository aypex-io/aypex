require "cancan"
require_dependency "aypex/controller_helpers/strong_parameters"

class Aypex::BaseController < ApplicationController
  include Aypex::ControllerHelpers::Auth
  include Aypex::ControllerHelpers::Search
  include Aypex::ControllerHelpers::Store
  include Aypex::ControllerHelpers::StrongParameters
  include Aypex::ControllerHelpers::Locale
  include Aypex::ControllerHelpers::Currency

  respond_to :html
end
