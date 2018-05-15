class MoodleController < ActiveRecord::Base
  establish_connection(DB_MOODLE)

  def self.enrolled_users(course_id)
    Moodle::Api.core_enrol_get_enrolled_users(courseid: Integer(course_id),
                                              options: [{:name => "userfields", :value => "fullname"}])
  rescue => error
    Rails.logger.debug("Could not get enrolled users for course #{course_id}. Message: #{error.message.inspect}")
    return []
  end

  def self.contents(course_id)
    contents = Moodle::Api.core_course_get_contents(courseid: Integer(course_id),
                                                    options: [{:name => "excludemodules", :value => "false"}])

    contents.map { |course|
      course["modules"].collect { |m|
        {id: m["id"], type: m["modname"], category: m["modplural"], title: m["name"]} if m["modname"].in? ApplicationController::MODULES_OF_INTEREST
      }.compact
    }.compact.flatten
  rescue => error
    Rails.logger.debug("Could not get contents for course #{course_id}. Message: #{error.message.inspect}")
    return []
  end

  def self.activities(course_id, users_hash)
    self.connection.exec_query("
        SELECT cmc.coursemoduleid, m.name, cm.instance, cmc.userid, cmc.completionstate
          FROM mdl_course_modules cm
          INNER JOIN 
            mdl_course_modules_completion cmc ON cm.id = cmc.coursemoduleid
          JOIN 
            mdl_modules m ON cm.module = m.id
          WHERE
            cm.course = #{Integer(course_id)} AND 
            cm.completion <> 0 AND 
            m.name IN (\"#{ApplicationController::MODULES_OF_INTEREST.join("\", \"")}\") AND
            cmc.userid IN (#{users_hash.keys.join(",").to_s});")
  end
end
