class AircraftAPI < Grape::API
  resource :aircraft do
    get do
      Aircraft.all
    end
  end
end
