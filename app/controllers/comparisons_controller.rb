class ComparisonsController < ApplicationController
  def index
    # Logic extracted out to a really judgey, judgey service
    # object in order to clean up the controller.
    render json: city_judge.comparison_data, status: 200
  end

private

  def city_judge
    # we have to use the IP from the request or this will end up
    # being the IP of the server
    @city_judge ||= CityJudge.new(ip: request.remote_ip)
  end
end
