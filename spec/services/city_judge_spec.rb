require 'rails_helper'

RSpec.describe CityJudge do
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

  subject { described_class.new(ip: '123.45.67.890') }

  before do
    expect_any_instance_of(AirVisualApi::City).to receive(:nearest_city_by_ip).and_return(local_city)
    expect_any_instance_of(AirVisualApi::City).to receive(:city_by_name_and_state).and_return(major_city)
  end

  it 'returns formatted pollution data' do
    stub_const('ComparisonsController::MAJOR_CITIES', {'Los Angeles' => 'California'})
    expect(subject.comparison_data).to eq(expected_response)
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
        local_air_data: {
          city: 'Los Angeles',
          state: 'California',
          air_quality: 8
        },
        comparable_city_data: {
          city: 'Chicago',
          state: 'Illinois',
          air_quality: 61,
          comparison_to_local: 53
        }
      }
    end

    it 'will always return a different city' do
      stub_const('ComparisonsController::MAJOR_CITIES', {'Los Angeles' => 'California', 'Chicago' => 'Illinois'})
      expect(subject.comparison_data).to eq(expected_response)
    end
  end
end
