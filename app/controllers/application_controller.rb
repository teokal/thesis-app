require 'elasticsearch'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :authenticate_user!
  protect_from_forgery with: :exception


  ES_CONTROLLER = EsController.new

  def index

  end

  def generate_csrf_token
    app_controller = ActionController::Base::ApplicationController.new
    app_controller.request = ActionDispatch::Request.new({})
    app_controller.send(:form_authenticity_token)
  end

end
