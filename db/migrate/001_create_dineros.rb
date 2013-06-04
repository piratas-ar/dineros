migration 1, :create_dineros do
  up do
    create_table :dineros do
      column :id, Integer, :serial => true
      column :cantidad, DataMapper::Property::Float
      column :responsable, DataMapper::Property::String, :length => 255
      column :comentario, DataMapper::Property::Text
    end
  end

  down do
    drop_table :dineros
  end
end
