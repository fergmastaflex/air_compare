require 'rails_helper'

RSpec.describe 'City comparison', type: :request do
  let(:local_city) do
    {
      "status" => "success",
      "data" => {
        "city" => "Arlington",
        "state" => "Virginia",
        "country" => "USA",
        "current" => {
          "pollution" => { "aqius"=> 8 }
        }
      }
    }
  end

  let(:major_city) do
    {
      "status" => "success",
      "data" => {
        "city" => 'Los Angeles',
        "state" => 'California',
        "country" => "USA",
        "current" => {
          "pollution" => { "aqius"=> 61 }
        }
      }
    }
  end

  let(:expected_response) do
    {
      local_air_quality: {
        city: 'Arlington',
        state: 'Virginia',
        air_quality: 8
      },
      comparable_city_quality: {
        city: 'Los Angeles',
        state: 'California',
        air_quality: 61,
        comparison_to_local: 53
      }
    }
  end

  before do
    expect_any_instance_of(AirVisualApi::City).to receive(:nearest_city_by_ip).and_return(local_city)
    expect_any_instance_of(AirVisualApi::City).to receive(:city_by_name_and_state).and_return(major_city)
  end

  it 'returns local pollution data compared to other cities' do
    stub_const('ComparisonsController::MAJOR_CITIES', {'Los Angeles' => 'California'})
    get '/comparisons'
    expect(response.body).to eq(expected_response.to_json)
    expect(response.status).to eq(200)
  end

  context 'local city in major cities list' do
    let(:local_city) do
      {
        "status" => "success",
        "data" => {
          "city" => "Los Angeles",
          "state" => "California",
          "country" => "USA",
          "current" => {
            "pollution" => { "aqius"=> 8 }
          }
        }
      }
    end

    let(:major_city) do
      {
        "status" => "success",
        "data" => {
          "city" => 'Chicago',
          "state" => 'Illinois',
          "country" => "USA",
          "current" => {
            "pollution" => { "aqius"=> 61 }
          }
        }
      }
    end

    let(:expected_response) do
      {
        local_air_quality: {
          city: 'Los Angeles',
          state: 'California',
          air_quality: 8
        },
        comparable_city_quality: {
          city: 'Chicago',
          state: 'Illinois',
          air_quality: 61,
          comparison_to_local: 53
        }
      }
    end

    it 'will always return a different city' do
      stub_const('ComparisonsController::MAJOR_CITIES', {'Los Angeles' => 'California', 'Chicago' => 'Illinois'})
      get '/comparisons'
      expect(response.body).to eq(expected_response.to_json)
    end
  end
end
