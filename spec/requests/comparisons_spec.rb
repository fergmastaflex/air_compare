require 'rails_helper'

RSpec.describe 'City comparison', type: :request do
  let(:comparison_data) do
    {
      local_air_data: {
        city: 'Arlington',
        state: 'Virginia',
        air_quality: 8
      },
      comparable_city_data: {
        city: 'Los Angeles',
        state: 'California',
        air_quality: 61,
        comparison_to_local: 53
      }
    }
  end

  before { expect_any_instance_of(CityJudge).to receive(:comparison_data).and_return(comparison_data) }

  it 'returns local pollution data compared to other cities' do
    get '/comparisons'
    expect(response.body).to eq(comparison_data.to_json)
    expect(response.status).to eq(200)
  end
end
