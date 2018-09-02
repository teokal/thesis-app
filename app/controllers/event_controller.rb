class EventController < ApplicationController

  def get_events
    events = Moodle::Api.core_calendar_get_calendar_events({})

    {
        events: events['events'].map do |event|
          {
              title: event['name'],
              start: DateTime.strptime(event['timestart'].to_s, '%s'),
              end: DateTime.strptime((event['timestart'] + event['timeduration']).to_s, '%s'),
              allDay: false,
              description: event['description']
          }
        end
    }

  end

end