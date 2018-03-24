class Api::V1::CourseController < Api::V1::ApiController

  def get_logs
    controller = ApplicationController::CourseController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.get_logs

    if response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response[:data])
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def get_course_contents
    controller = ApplicationController::CourseController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.get_course_contents

    if response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response[:data])
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def get_course_contents_logs
    controller = ApplicationController::CourseController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.get_course_contents_logs

    if response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response[:data])
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def get_course_modules
    controller = ApplicationController::CourseController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.get_course_modules

    if response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response[:data])
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def get_enrolled_users
    controller = ApplicationController::CourseController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.enrolled_users

    if response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response[:data])
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def get_risk_analysis
    controller = ApplicationController::RiskAnalysisController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.get_risk_analysis

    if response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response[:data])
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def transform_risk_analysis_data
    controller = ApplicationController::RiskAnalysisController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.transform_risk_analysis_data

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