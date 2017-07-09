class  Api::V1::UserController <  Api::V1::ApiController

  def show
    controller = ApplicationController::UserController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.show(@user)

    if response[:type] == :error
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
    response = controller.courses(@user)

    if response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response[:courses])
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

end