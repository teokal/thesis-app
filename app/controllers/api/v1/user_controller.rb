class Api::V1::UserController < Api::V1::ApiController
  skip_before_filter :authenticate_user!, only: [:sign_in]

  def sign_in
    username = params[:username]
    password = params[:password]

    token = get_moodle_token(username, password)
    if token.class == String
      @user = User.find_by(username: username)
      @user.update({
                       access_token: SecureRandom.hex(30),
                       moodle_token: token,
                       moodle_user_id: 3,
                       expires_at: 5.days.from_now
                   })
      success_response(data: {token: @user.access_token})
    else
      error_response(data: 'User could not be authenticated')
    end
  end

  def get_moodle_token(username = '', password = '')
    begin
      configuration = Moodle::Api::Configuration.new({host: ENV['MOODLE_HOST_URL'], service: ENV['MOODLE_SERVICE_SHORT'],
                                                      username: username, password: password})
      Moodle::Api::TokenGenerator.new(configuration).call
    rescue => error
      Rails.logger.debug("[DEBUG] API | Sign_in | Could not authenticate user: #{username}, #{error}")
      false
    end
  end

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