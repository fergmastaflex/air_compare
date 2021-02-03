# I don't normally do cute names, but this just
# felt fun to me. It's judging cities! Look at
# how judgemental this Ruby object is!

require 'airvisual_api'

class CityJudge

  MAJOR_CITIES = {
    'Los Angeles' => 'California',
    'Chicago' => 'Illinois',
    'Washington' => 'Washington D.C.',
    'New York City' => 'New York',
    'Dallas' => 'Texas'
  }.freeze

  def initialize(ip:)
    @ip = ip
  end

  def comparison_data
    {
      local_air_data: pollution_data(full_local_data),
      comparable_city_data: pollution_data(full_major_city_data).merge(
        comparison_to_local: pollution_difference
      )
    }
  end

private

  attr_reader :ip

  def full_local_data
    @full_local_data ||= airvisual_client.nearest_city_by_ip(ip: ip)['data']
  end

  def pollution_data(data)
    {
      city: data['city'],
      state: data['state'],
      air_quality: data.dig('current','pollution','aqius')
    }
  end

  def full_major_city_data
    @full_major_city_data ||= begin
      # Picks a random city from the list that is not the user's.
      # Originally this iterated through each city, but that was
      # obviously hitting rate limits. Future iterations could allow
      # the user to pick from a list, but I'm only making
      # a simple prototype API for now.
      city, state = MAJOR_CITIES.to_a.reject do |city|
        city.include?(full_local_data['city'])
      end.sample

      airvisual_client.city_by_name_and_state(
        city: city,
        state: state
      ).dig('data')
    end
  end

  def pollution_difference
    full_major_city_data.dig('current','pollution','aqius') - full_local_data.dig('current','pollution','aqius')
  end

  def airvisual_client
    @airvisual_client ||= AirVisualApi::City.new
  end
end
