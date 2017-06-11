class Api::V1::ApiController < RocketPants::Base
  before_action :authenticate_access

  RocketPants::Base.version 1

  def test
    id = params[:id].blank? ? 0 : params[:id]
    data = { id: id,
             message: "Test #{id}",
             authorized: @user_access }
    success_response(data: data)

  rescue => error
    Rails.logger.error(error.message)
    error_response(type: :internal_error)
  end


  def logs_per_action
    cont = EsController.new
    response = cont.actions(params[:from], params[:to], params[:query], params[:view])
    success_response(data: response)

  rescue => error
    Rails.logger.error(error.message)
    error_response(type: :internal_error)
  end

  protected

  def authenticate_access
    Rails.logger.info("REMOTE_ADDR: #{request.env['REMOTE_ADDR']}")
    if authenticate_entity_access
      @user_access = true
    elsif params[:action] == 'test'
      @user_access = false
    else
      @user_access = false
      render_unauthorized
    end
  end

  def authenticate_entity_access
    authenticate_with_http_token do |access_token, options|
      @user = User.find_by(access_token: access_token)
      return true unless @user.nil?
      return false
    end
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    error_response(status: :error, type: :unauthorized, message: 'Bad Token')
  end

  def set_access
    @response.headers['Access-Control-Allow-Origin'] = '*'
  end

  def success_response(additional_fields = {})
    if additional_fields[:message].blank?
      additional_fields = additional_fields.merge(message: :ok)
    end

    response_body = {
        status: :success,
        type: :ok
    }.merge(additional_fields)

    expose(response_body)
  end

  def error_response(additional_fields = {})
    if additional_fields[:type].blank?
      additional_fields = additional_fields.merge(type: :bad_request)
    end

    response_body = {
        status: :error,
    }.merge(additional_fields)

    expose(response_body)
  end

end
