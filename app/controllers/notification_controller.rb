class NotificationController < ApplicationController
  def notifications
    notifications = Moodle::Api.core_fetch_notifications(contextid: params[:context_id])
    if notifications.blank?
      {type: :error, message: "No new notifications."}
    else
      {data: notifications}
    end
  end
end
