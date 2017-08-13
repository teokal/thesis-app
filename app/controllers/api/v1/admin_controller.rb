class Api::V1::AdminController < Api::V1::ApiController

  def logs
    controller = ApplicationController::UserController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.logs

    if response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response[:data])
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

end