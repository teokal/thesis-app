class  Api::V1::UserController <  Api::V1::ApiController

  def get
    controller = ApplicationController::UserController.new
    response = controller.show(params[:id])

    response = response.as_json(only: :id)

    data = response.nil? ? 'User not found' : response
    success_response(data: data)
  end

end