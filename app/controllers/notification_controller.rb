class NotificationController < ApplicationController

  def notifications
    notifications = Moodle::Api.core_fetch_notifications(contextid: params[:contextid])
    if notifications.blank?
      {type: :error, message: 'No notifications'}
    else
      {data: notifications}
    end
  end

end
