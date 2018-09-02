class Api::V1::CourseCategoryController < Api::V1::ApiController
  def index
    controller = ApplicationController::CourseCategoryController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.index(@user)

    if response.class == Hash && response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response)
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def create
    controller = ApplicationController::CourseCategoryController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.create(@user)

    if response.class == Hash && response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response)
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def delete
    controller = ApplicationController::CourseCategoryController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.delete(@user)

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
