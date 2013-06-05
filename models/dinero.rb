class Dinero
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :cantidad, Integer, :required => true
  property :responsable, String, :required => true, :format => :email_address
  property :comentario, Text
  property :fecha, DateTime
end
