module Harvesting
  module Models
    class Client < Base
      attributed :id,
                 :name,
                 :is_active,
                 :address,
                 :created_at,
                 :updated_at,
                 :currency

    end
  end
end
