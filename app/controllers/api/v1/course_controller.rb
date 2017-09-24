class Api::V1::CourseController < Api::V1::ApiController

  def show
    controller = ApplicationController::CourseController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.show(params[:id])

    if response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response)
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def logs
    controller = ApplicationController::CourseController.new
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

  def module_logs
    controller = ApplicationController::CourseController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.module_logs

    if response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response[:data])
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def module_resources_logs
    controller = ApplicationController::CourseController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.module_resources_logs

    if response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response[:data])
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def course_resources
    controller = ApplicationController::CourseController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.course_resources

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