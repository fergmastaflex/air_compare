# I really debated on whether I wanted to have a
# more general controller like this one rather than a number of controllers
# that are better based on resources. I decided to combine
# the data to one request like this 1.) because of the parameters of the
# assignment (returning a combined JSON object) and 2.) to reduce
# requests from the frontend. I'm kind of a purist when it comes
# to REST API design, but I'm also fairly pragmatic. This made sense
# to me, but I welcome feedback.

class ComparisonsController < ApplicationController
  def index
    # Logic extracted out to a really judgey, judgey service
    # object in order to clean up the controller.
    # I'm also not really adhering to any particular serialization format
    # but that can be changed.
    render json: city_judge.comparison_data, status: 200
  end

private

  def city_judge
    # we have to use the IP from the request or this will end up
    # being the IP of the server
    @city_judge ||= CityJudge.new(ip: request.remote_ip)
  end
end
