class Api::V1::UserController < Api::V1::ApiController

  def info
    controller = ApplicationController::UserController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.info

    if response.class == Hash && response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response)
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def courses
    controller = ApplicationController::UserController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.courses

    if response.class == Hash && response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response)
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def statistics
    controller = ApplicationController::UserController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.statistics

    if response.class == Hash && response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response)
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

end