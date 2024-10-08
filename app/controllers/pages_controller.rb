class PagesController < ApplicationController
  before_action :authenticate_student!,
                only: %i[enrollement documents profile dashboard create_semester_registration]
  # layout false, only: [:home]
  def home
    # authenticate_student!
  end

  def admission; end

  def documents; end

  def digital_iteracy_quiz; end

  def requirement; end

  def profile
    @address = current_student.student_address
    @emergency_contact = current_student.emergency_contact
  end

  def dashboard
    @address = current_student.student_address
    @emergency_contact = current_student.emergency_contact
    @invoice = Invoice.find_by(student: current_student, semester: current_student.semester, year: current_student.year)
    @smr = current_student.semester_registrations.where(year: current_student.year,
                                                        semester: current_student.semester).last
    @payment_remaining = current_student.semester_registrations.where('remaining_amount > ?', 0).last if @smr.nil?
  end

  def moodle_login
    username = params[:username]
    password = params[:password]
    moodle_service = MoodleApiService.new('9ab5a994a496d4424dd40777b57a129c')
    user = moodle_service.get_user_by_username(username)

    if user['users'].any?
      # User found in Moodle
      redirect_url = moodle_service.generate_sso_url(user['users'].first)
      redirect_to redirect_url
    else
      raise 'Invalid credentials or user not found'
    end
    # begin
    #   moodle_service = MoodleApiService.new('your_moodle_token_here')
    #   user = moodle_service.get_user_by_username(username)

    #   if user['users'].any?
    #     # User found in Moodle
    #     redirect_url = moodle_service.generate_sso_url(user['users'].first)
    #     redirect_to redirect_url
    #   else
    #     raise 'Invalid credentials or user not found'
    #   end
    # rescue => e
    #   flash[:alert] = "Login failed: #{e.message}"
    #   redirect_to dashboard_path
    # end
  end

  def enrollement
    @total_course = current_student.get_current_courses
    @registration_fee = current_student.get_registration_fee
    @tution_fee = current_student.get_tution_fee
    # @total = @registration_fee + tution_fee
  end

  def create_semester_registration
    mode_of_payment = params[:mode_of_payment]
    # total_course = Student.get_current_courses(current_student).size
    registration = current_student.add_student_registration(mode_of_payment:)
    respond_to do |format|
      if registration.save
        format.html do
          redirect_to invoice_path(registration.invoices.last.id), notice: 'Registration was successfully created.'
        end
        format.json { render :show, status: :ok, location: registration }
      else
        format.html { redirect_to :enrollement_path, alert: 'Something went wrong please try again' }
        format.json { render json: registration.errors, status: :unprocessable_entity }
      end
    end
  end
end
