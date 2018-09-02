class NotificationController < ApplicationController
  def notifications
    context_id = 10 # params[:context_id]
    notifications = Moodle::Api.core_fetch_notifications(contextid: context_id)
    if notifications.blank?
      {type: :error, message: "No new notifications."}
    else
      {data: notifications}
    end
  end
end
