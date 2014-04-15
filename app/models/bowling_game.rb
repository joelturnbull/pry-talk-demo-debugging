class BowlingGame < ActiveRecord::Base
  has_many :throws

  def frames
    throws.each_slice(2) 
  end
end
