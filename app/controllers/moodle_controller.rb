class MoodleController < ActiveRecord::Base
  establish_connection(DB_MOODLE)

  def self.enrolled_users(course_id)
    Moodle::Api.core_enrol_get_enrolled_users(courseid: Integer(course_id),
                                              options: [{:name => "userfields", :value => "fullname"}])
  rescue => error
    Rails.logger.debug("[DEBUG] Could not get enrolled users for course #{course_id}. Message: #{error.message.inspect}")
    return []
  end

  def self.contents(course_id)
    contents = Moodle::Api.core_course_get_contents(courseid: Integer(course_id),
                                                    options: [{:name => "excludemodules", :value => "false"}])

    contents.map { |course|
      course["modules"].collect { |m|
        {id: m["id"], module: "course_module", type: m["modname"], category: m["modplural"], title: m["name"]} if m["modname"].in? ApplicationController::MODULES_OF_INTEREST
      }.compact
    }.compact.flatten.sort_by { |x| [x[:modname], x[:title]] }
  rescue => error
    Rails.logger.debug("[DEBUG] Could not get contents for course #{course_id}. Message: #{error.message.inspect}")
    return []
  end

  def self.activities(course_id, users_hash, dates)
    dates = {
      from: dates[:from].blank? ? 0 : Time.parse(dates[:from]).to_i,
      to: dates[:from].blank? ? Time.now.end_of_day.to_i : Time.parse(dates[:to]).to_i,
    }

    self.connection.exec_query("
        SELECT cmc.coursemoduleid, m.name, cm.instance, cmc.userid, cmc.completionstate
          FROM #{ENV["MOODLE_DB_PREFIX"]}course_modules cm
          INNER JOIN 
          #{ENV["MOODLE_DB_PREFIX"]}course_modules_completion cmc ON cm.id = cmc.coursemoduleid
          JOIN 
          #{ENV["MOODLE_DB_PREFIX"]}modules m ON cm.module = m.id
          WHERE
            cm.course = #{Integer(course_id)} AND 
            cm.completion <> 0 AND 
            m.name IN (\"#{ApplicationController::MODULES_OF_INTEREST.join("\", \"")}\") AND
            cmc.userid IN (#{users_hash.keys.join(",").to_s}) AND 
            cmc.timemodified >= #{dates[:from]} AND cmc.timemodified <= #{dates[:to]};")
  end
end
