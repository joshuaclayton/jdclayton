class HomeController < ApplicationController
  caches_page :index
  
  def index
    dob = Date.parse("8/21/1983")
    @age = Date.today.year - dob.year
    @age -= 1 if Date.today.month < dob.month || (Date.today.month == dob.month && Date.today.day <= dob.day)
  end
end
