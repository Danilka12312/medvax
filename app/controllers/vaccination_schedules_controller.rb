class VaccinationSchedulesController < ApplicationController
  def index
    @vaccination_schedules = VaccinationSchedule.where('vaccination_date > ? OR (vaccination_date = ? AND vaccination_time >= ?)', Date.today, Date.today, Time.now).order(vaccination_date: :asc, vaccination_time: :asc)
  end

  def new
    @schedule = VaccinationSchedule.new
    @personals = Personal.all
    @vaccines = Vaccine.all
    @rooms = Room.all
  end

  def edit
    @schedule = VaccinationSchedule.find(params[:id])
  end

  def update
    @schedule = VaccinationSchedule.find(params[:id])
    if @schedule.update(schedule_params)
      redirect_to vaccination_schedules_path, notice: 'Расписание успешно обновлено'
    else
      render 'edit'
    end
  end

  def create
    @schedule = VaccinationSchedule.new(schedule_params)

    if schedule_conflicts?(@schedule)
      render :new, alert: 'Сотрудник уже записан на вакцинацию на этой неделе или имеет эту вакцину в последние 30 дней.'
    elsif @schedule.save
      redirect_to vaccination_schedules_path, notice: 'Расписание успешно создано.'
    else
      render :new
    end
  end

  private

  def schedule_conflicts?(schedule)
    # Проверка на наличие записи на этой неделе
    start_of_week = schedule.vaccination_date.beginning_of_week
    end_of_week = schedule.vaccination_date.end_of_week

    weekly_conflict = VaccinationSchedule.exists?(
      personal_id: schedule.personal_id,
      vaccination_date: start_of_week..end_of_week
    )

    # Проверка на наличие той же вакцины в последние 30 дней
    start_date = schedule.vaccination_date - 30.days
    vaccine_conflict = VaccinationSchedule.exists?(
      personal_id: schedule.personal_id,
      vaccine_id: schedule.vaccine_id,
      vaccination_date: start_date..schedule.vaccination_date
    )

    weekly_conflict || vaccine_conflict
  end

  def show
    @schedule = VaccinationSchedule.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to vaccination_schedules_path, alert: 'Расписание не найдено.'
  end

  def new_schedule_for_period
  end

  def calendar
    @current_month = params[:month] ? Date.parse(params[:month]) : Date.today.beginning_of_month
    @vaccination_schedules = VaccinationSchedule.where('vaccination_date > ? OR (vaccination_date = ? AND vaccination_time >= ?)', Date.today, Date.today, Time.now).order(vaccination_date: :asc, vaccination_time: :asc)
    @schedules = VaccinationSchedule.where(vaccination_date: @current_month.beginning_of_month..@current_month.end_of_month).group_by { |schedule| schedule.vaccination_date }
  end

  def show_day
    @date = Date.parse(params[:date])
    @schedules = VaccinationSchedule.where(vaccination_date: @date)
  end

  def filter_schedules
    @today_schedules = if params[:room_id].present?
                          VaccinationSchedule.where(vaccination_date: Date.today, room_id: params[:room_id])
                        else
                           VaccinationSchedule.where(vaccination_date: Date.today)
                         end

      render partial: 'schedules_list', locals: { schedules: @today_schedules }
  end

   def generate_automatic_schedules
    Rails.logger.info "Starting automatic schedule generation"
    employees = Personal.all
    vaccines = Vaccine.where(mandatory: true)
    rooms = Room.all
    current_date = Date.today.beginning_of_month

    while current_date <= Date.today.end_of_month
      if (1..5).include?(current_date.wday) # Только по будням
        current_time = current_date.to_time.change(hour: 10) # Начало с 10 утра

        while current_time.hour < 16
          rooms.each do |room|
            Rails.logger.info "Checking room: #{room.name} on #{current_date} at #{current_time}"
            # Найти свободное время в этом кабинете
            unless VaccinationSchedule.where(room: room, vaccination_date: current_date, vaccination_time: current_time).exists?
              employees.each do |employee|
                vaccines.each do |vaccine|
                  next if employee.vaccinations.exists?(vaccine: vaccine) || VaccinationSchedule.exists?(personal: employee, vaccine: vaccine)

                  last_schedule = VaccinationSchedule.where(personal: employee, vaccine: vaccine).order(vaccination_date: :desc).first
                  if last_schedule && (current_date - last_schedule.vaccination_date).to_i < 10
                    next
                  end

                  schedule = VaccinationSchedule.new(
                    personal: employee,
                    vaccine: vaccine,
                    room: room,
                    vaccination_date: current_date,
                    vaccination_time: current_time
                  )
                  if schedule.save
                    Rails.logger.info "Created schedule for #{employee.fio}, #{vaccine.name} at #{current_time}"
                  else
                    Rails.logger.error "Failed to create schedule: #{schedule.errors.full_messages.join(', ')}"
                  end

                  current_time += 10.minutes
                  break if current_time.hour >= 16
                end
                break if current_time.hour >= 16
              end
            end
            break if current_time.hour >= 16
          end
        end
      end
      current_date += 1.day
    end

    redirect_to vaccination_schedules_path, notice: 'Автоматическое расписание вакцинации успешно создано.'
  end

  private

  def schedule_params
    params.require(:vaccination_schedule).permit(:personal_id, :vaccine_id, :room_id, :vaccination_date, :vaccination_time)
  end
end
