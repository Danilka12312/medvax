# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  helper PagesHelper

  def home
    @current_month = params[:month] ? Date.strptime(params[:month], "%Y-%m") : Time.current.beginning_of_month
    @expiring_vaccinations = expiring_vaccinations(@current_month)
  end

  private

  def expiring_vaccinations(date)
    start_date = date.beginning_of_month
    end_date = date.end_of_month

    Vaccination.joins(:vaccine).where("DATE(vaccination_date, '+' || vaccines.expiry_date || ' days') BETWEEN ? AND ?", 
                                      start_date, 
                                      end_date)
  end
end
