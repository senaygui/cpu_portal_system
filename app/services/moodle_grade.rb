require 'net/https'

module MoodleGrade
  class << self
    def moodle_grade(cr)
      is_fetched = false
      url = URI('https://lms.cpucollege.edu.et/webservice/rest/server.php')
      moodle = MoodleRb.new('9ab5a994a496d4424dd40777b57a129c', 'https://lms.cpucollege.edu.et/webservice/rest/server.php')
      lms_student = moodle.users.search(email: "#{student_grade.student.email}")
      courses = moodle.courses
      lms_course = courses.search("#{cr.course.course_code}")
      if lms_student.any? || lms_course['courses'].any?
        course_id = lms_course['courses'].last['id']
        user_id = lms_student.last['id']
        grade = courses.grade_items(course_id, user_id).last
        result = grade['gradeitems'].last
        letter_grade = result['gradeformatted']
        assesment_total = result['graderaw']
        grade_point = get_grade_point(letter_grade, credit_hour)
        student = StudentGrade.new(student_id: cr.student_id, course_registration_id: cr.id, course_id: cr.course_id,
                                   program_id: cr.program_id, department_id: cr.department_id, assesment_total:, letter_grade:, grade_point:)
        is_fetched = true if student.save
      end
      is_fetched
    end

    private

    def get_grade_point(grade_letter, credit_hour)
      grade_letter = grade_letter.upcase
      if ['A', 'A+'].include?(grade_letter)
        4 * credit_hour
      elsif grade_letter == 'A-'
        3.75 * credit_hour
      elsif grade_letter == 'B+'
        3.5 * credit_hour
      elsif grade_letter == 'B'
        3 * credit_hour
      elsif grade_letter == 'B-'
        2.75 * credit_hour
      elsif grade_letter == 'C+'
        2.5 * credit_hour
      elsif grade_letter == 'C'
        2 * credit_hour
      elsif grade_letter == 'C-'
        1.75 * credit_hour
      elsif grade_letter == 'D'
        1 * credit_hour
      elsif grade_letter == 'F'
        0
      end
    end
  end
end
