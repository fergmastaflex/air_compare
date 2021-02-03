require 'airvisual_api'

class ComparisonsController < ApplicationController

  MAJOR_CITIES = {
    'Los Angeles' => 'California',
    'Chicago' => 'Illinois',
    'Washington' => 'Washington D.C.',
    'New York City' => 'New York',
    'Dallas' => 'Texas'
  }.freeze

  AQIUS_ATTRIBUTES = ['data','current','pollution','aqius'].freeze

  def index
    render json: comparison_response, status: 200
  end

private

  def airvisual_client
    @airvisual_client ||= AirVisualApi::City.new
  end

  def local_air_quality
    @local_air_quality ||= airvisual_client.nearest_city_by_ip(ip: request.remote_ip)
  end

  def major_city_quality
    city, state = MAJOR_CITIES.to_a.reject { |city| city.include?(local_air_quality['data']['city']) }.sample
    city_quality = airvisual_client.city_by_name_and_state(city: city, state: state).dig(*AQIUS_ATTRIBUTES)
    {
      city: city,
      state: state,
      air_quality: city_quality,
      comparison_to_local: city_quality - local_air_quality.dig(*AQIUS_ATTRIBUTES)
    }
  end

  def comparison_response
    {
      local_air_quality: {
        city: local_air_quality['data']['city'],
        state: local_air_quality['data']['state'],
        air_quality: local_air_quality.dig(*AQIUS_ATTRIBUTES)
      }
    }.merge(comparable_city_quality: major_city_quality)
  end
end
