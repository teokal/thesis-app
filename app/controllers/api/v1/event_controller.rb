class Api::V1::EventController < Api::V1::ApiController

  def get_events
    controller = ApplicationController::EventController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.get_events

    if response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(events: response[:events])
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

end