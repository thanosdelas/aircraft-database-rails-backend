class AircraftAPI < Grape::API
  resource :aircraft do
    get do
      # OpenskyNetworkRaw.limit(2000)
      Aircraft.all
    end
  end
end
