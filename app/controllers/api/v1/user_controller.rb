class Api::V1::UserController < Api::V1::ApiController
  def sign_in
    username = params[:username]
    password = params[:password]

    token = get_moodle_token(username, password)
    if token.class == String
      @user = User.find_by(username: username)
      user_info = get_moodle_user_info(token)

      if @user.blank?
        @user = User.create(username: username, email: "")
        @user.save(validate: false)
      end

      @user.update({
                     first_name: user_info["firstname"],
                     last_name: user_info["lastname"],
                     full_name: user_info["fullname"],
                     access_token: SecureRandom.hex(64),
                     moodle_token: token,
                     moodle_user_id: user_info["userid"],
                     expires_at: 8.hour.from_now,
                     picture_url: user_info["userpictureurl"],
                   })

      success_response(
        user: @user.as_json({
          only: [:username, :first_name, :last_name,
                 :full_name, :picture_url, :access_token],
        }),
      )
    else
      error_response(data: "User could not be authenticated")
    end
  end

  def get_moodle_token(username = "", password = "")
    begin
      configuration = Moodle::Api::Configuration.new({host: ENV["MOODLE_HOST_URL"], service: ENV["MOODLE_SERVICE_SHORT"],
                                                      username: username, password: password})
      Moodle::Api::TokenGenerator.new(configuration).call
    rescue => error
      Rails.logger.debug("[DEBUG] API | get_moodle_token | Could not get user token #{username}, #{error}")
      false
    end
  end

  def get_moodle_user_info(user_token)
    begin
      Moodle::Api.configure({host: ENV["MOODLE_HOST_URL"], token: user_token})
      Moodle::Api.core_webservice_get_site_info({})
    rescue => error
      Rails.logger.debug("[DEBUG] API | get_moodle_user_info | Could not get user info, #{error}")
      false
    end
  end

  def info
    controller = ApplicationController::UserController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.info(@user, params[:user_id])

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
    response = controller.courses(@user)

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
    response = controller.statistics(@user)

    if response.class == Hash && response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response)
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def send_message
    controller = ApplicationController::UserController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.send_message(@user)

    if response.class == Hash && response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response)
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def custom_activities_index
    controller = ApplicationController::UserController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.custom_activities_index(@user)

    if response.class == Hash && response[:type] == :error
      success_response(type: :error, message: response[:message])
    else
      success_response(data: response)
    end
  rescue => error
    Rails.logger.debug(error.message)
    error_response
  end

  def custom_activities_update
    controller = ApplicationController::UserController.new
    controller.request = ActionDispatch::Request.new(request.env)
    response = controller.custom_activities_update(@user)

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
