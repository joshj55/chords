class Instrument < ActiveRecord::Base
  belongs_to :site
  has_many :measurements, :dependent => :destroy
  has_many :vars, :dependent => :destroy
  accepts_nested_attributes_for :vars
  
  def self.initialize
#    Instrument.create([{name: 'Campbell', site_id:'1', }])
#    Instrument.create([{name: 'Campbell', site_id:'2', }])
#    Instrument.create([{name: 'Campbell', site_id:'3', }])

#    Instrument.create([{name: '449 Profiler', site_id:'2', }])

#    Instrument.create([{name: '915 Profiler', site_id:'1', }])
#    Instrument.create([{name: '915 Profiler', site_id:'3', }])    
  end


  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |rails_model|
        csv << rails_model.attributes.values_at(*column_names)
      end
    end
  end


  def self.data_insert_url
    url = instrument_url()
  end


  def last_measurement
    measurement = Measurement.where("instrument_id = ?", self.id).order(:measured_at).last
    # logger.debug()
    return measurement
  end
  
  def is_receiving_data
    measurement = Measurement.where("(instrument_id = ?) AND (measured_at > ?)", self.id, self.seconds_before_timeout.seconds.ago).order(:measured_at).last
    if measurement
      printf "is_receiving_data returning true"
      return TRUE
    else
      return FALSE
    end
    
  end
  
  def last_age
    measurement = measurements.last
    if measurement
      return measurement.age
    end
    return 'never'
  end

  def data(count, parameter)

    measurements = Measurement.where("instrument_id = ? and parameter = ?", self.id, parameter).last(self.display_points)
    
    data = Array.new    
    measurements.each do |measurement|
      t = Time.new(measurement.measured_at.year, measurement.measured_at.month, measurement.measured_at.day, measurement.measured_at.hour, measurement.measured_at.min, measurement.measured_at.sec, "+00:00")

      x=((t.to_i) * 1000).to_s
      data.push "[#{x}, #{measurement.value}]" 
      
    end

    return data.join(', ')
    
  end
      
end
