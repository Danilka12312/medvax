json.extract! vaccine, :id, :name, :manufacturer, :storage_conditions, :description, :expiry_date, :created_at, :updated_at
json.url vaccine_url(vaccine, format: :json)
