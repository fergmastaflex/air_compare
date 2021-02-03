class ComparisonsController < ApplicationController
  def index
    render json: city_judge.comparison_data, status: 200
  end

private

  def city_judge
    @city_judge ||= CityJudge.new(ip: request.remote_ip)
  end
end
