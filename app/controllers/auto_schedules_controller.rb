class AutoSchedulesController < ApplicationController
  def generate
    employees = Personal.all
    vaccines = Vaccine.where(mandatory: true)
    rooms = Room.all
    current_date = Date.tomorrow.beginning_of_day # Начать с завтрашнего дня

    while current_date <= Date.today.end_of_month
      if (1..5).include?(current_date.wday) # Только по будням
        current_time = current_date.to_time.change(hour: 10) # Начало с 10 утра

        while current_time.hour < 16
          room_found = false
          rooms.each do |room|
            unless VaccinationSchedule.where(room: room, vaccination_date: current_date, vaccination_time: current_time).exists?
              room_found = true
              break
            end
          end

          if room_found
            employees.each do |employee|
              assigned_dates = {} # Хранение уже назначенных дат для сотрудника

              vaccines.each do |vaccine|
                unless employee.vaccinations.exists?(vaccine: vaccine) || VaccinationSchedule.exists?(personal: employee, vaccine: vaccine)
                  last_schedule = VaccinationSchedule.where(personal: employee, vaccine: vaccine).order(vaccination_date: :desc).first

                  # Найти следующую доступную дату через 7 дней
                  next_available_date = last_schedule ? last_schedule.vaccination_date + 7.days : current_date

                  while assigned_dates.values.include?(next_available_date)
                    next_available_date += 7.days
                  end

                  schedule = VaccinationSchedule.new(
                    personal: employee,
                    vaccine: vaccine,
                    room: rooms.find { |room| !VaccinationSchedule.where(room: room, vaccination_date: next_available_date, vaccination_time: current_time).exists? },
                    vaccination_date: next_available_date,
                    vaccination_time: current_time
                  )

                  if schedule.save
                    Rails.logger.info "Created schedule for #{employee.fio}, #{vaccine.name} at #{current_time}"
                    assigned_dates[vaccine.id] = next_available_date
                  else
                    Rails.logger.error "Failed to create schedule: #{schedule.errors.full_messages.join(', ')}"
                  end
                end
              end
            end
          end

          current_time += 10.minutes
        end
      end
      current_date += 1.day
    end

    redirect_to calendar_vaccination_schedules_path, notice: 'Автоматическое расписание вакцинации успешно создано.'
  end
end
