class BulkDownload
  attr_accessor :random_job_id   # Define a unique string for this job
  attr_accessor :creation_time   # Time to be used in file naming
  attr_accessor :profile         # The portal profile config

  attr_accessor :start_time
  attr_accessor :end_time
  
  attr_accessor :instrument_ids
  attr_accessor :include_test_data
  attr_accessor :site_fields
  attr_accessor :instrument_fields
  attr_accessor :var_fields
  attr_accessor :create_separate_instrument_files


  def initialize(*args)
    @random_job_id  = SecureRandom.hex(10)
    @creation_time  = Time.now
    @profile        = Profile.first


    # if (args.count > 0)
      @start_time                       = Time.parse(args[0])
      @end_time                         = Time.parse(args[1])

      @instrument_ids                   = args[2]
      @include_test_data                = args[3]
      @site_fields                      = args[4]
      @instrument_fields                = args[5]
      @var_fields                       = args[6]
      @create_separate_instrument_files = args[7]
    # end

    # Make sure the tmp dir exists
    require 'fileutils'
    FileUtils.mkpath(BulkDownload.processing_dir)

  end

  def creation_time_string
    self.creation_time.strftime('%Y-%m-%d_%H-%M-%S')
  end



  def header_row_file_path
    header_row_file_name = "#{self.random_job_id}_header_row.csv"

    return "#{BulkDownload.processing_dir}/#{header_row_file_name}"
  end


  def header_row_zip_file_path
    return "#{self.header_row_file_path}.gz"
  end  


  def final_file_name_base    
    return "#{self.profile_string}_#{self.creation_time_string}"
  end


  def final_file_path
    return "#{BulkDownload.tmp_dir}/#{self.final_file_name_base}.csv.gz" 
  end

  def placeholder_file_path
    return "#{BulkDownload.tmp_dir}/#{self.final_file_name_base}.temp"
  end


  def profile_string
    self.profile.project.parameterize
  end


  def instrument_final_file_name_base(instrument)
    site_string           = instrument.site.name.parameterize
    instrument_string     = instrument.name.parameterize
    instrument_id_string  = "inst-id-#{instrument.id}"

    return "#{self.profile_string}_#{site_string}_#{instrument_string}_#{instrument_id_string}_#{self.creation_time_string}"
  end


  def csv_header
  end


  def instrument_csv_header
  end




  def row_labels
    row_labels = Array.new

    row_labels.push('measurement_time')
    row_labels.push('measurement_value')
    row_labels.push('is_test_value')

    prefix = 'site'
    self.site_fields.each do |field|
      label = ["#{prefix}_#{field}".parameterize.underscore]
      row_labels.push(label.to_csv.to_s.chomp.dump)
    end

    prefix = 'instrument'
    self.instrument_fields.each do |field|
      label = ["#{prefix}_#{field}".parameterize.underscore]
      row_labels.push(label.to_csv.to_s.chomp.dump)
    end

    prefix = 'var'
    self.var_fields.each do |field|
      label = ["#{prefix}_#{field}".parameterize.underscore]
      row_labels.push(label.to_csv.to_s.chomp.dump)
    end

    row_label = row_labels.join(',') + "\n"
    
    return row_label
  end





  def self.default_site_fields
    site_fields = {
      'id'              => true,
      'name'            => true,
      'lat'             => true,
      'lon'             => true,
      'elevation'       => true,
      'site_type.name'  => false,
    }

    # Sites
    # t.string "name"
    # t.decimal "lat", precision: 12, scale: 9
    # t.decimal "lon", precision: 12, scale: 9
    # t.decimal "elevation", precision: 12, scale: 6, default: "0.0"
    # t.integer "site_type_id"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false
    # t.text "description"

    # Site Types
    # t.string "name"
    #   t.text "definition"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false


    return site_fields
  end


def self.default_instrument_fields
    instrument_fields = {
      'id'                  => true,
      'name'                => true,
      'sensor_id'           => true,
      'description'         => false,
      'display_points'      => false,
      'sample_rate_seconds' => false,

      'topic_category.name' => false,
    }

    # Instruments
    # t.string "name"
    # t.string "sensor_id"
    # t.integer "display_points", default: 120
    # t.integer "sample_rate_seconds", default: 60
    #   t.integer "site_id"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false
    #   t.text "last_url"
    #   t.text "description"
    #   t.integer "plot_offset_value", default: 1
    #   t.string "plot_offset_units", default: "weeks"
    #   t.integer "topic_category_id"
    #   t.boolean "is_active", default: true
    #   t.bigint "measurement_count", default: 0, null: false
    #   t.bigint "measurement_test_count", default: 0, null: false

    # Topic Category
    # t.string "name"
    #   t.text "definition"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false

    return instrument_fields
  end


  def self.default_var_fields
    var_fields = {
      'name'                      => true,
      'shortname'                 => true,
      'general_category'          => true,
      'minimum_plot_value'        => false,
      'maximum_plot_value'        => false,

      'measured_property.name'    => false,
      'measured_property.label'   => false,
      'measured_property.url'     => false,
      'measured_property.source'  => false,

      'unit.name'                 => true,
      'unit.abbreviation'         => true,
      'unit.id_num'               => false,
      'unit.unit_type'            => false,
      'unit.source'               => false,
    }

    # Vars
    # t.string "name"
    # t.integer "instrument_id"
    # t.datetime "created_at", null: false
    # t.datetime "updated_at", null: false
    # t.string "shortname"
    # t.integer "measured_property_id", default: 795, null: false
    # t.float "minimum_plot_value"
    # t.float "maximum_plot_value"
    # t.integer "unit_id", default: 1
    # t.string "general_category", default: "Unknown"

    # Measured Properties
    # t.string "name"
    # t.string "label"
    # t.string "url"
    # t.text "definition"
    # t.datetime "created_at", null: false
    # t.datetime "updated_at", null: false
    # t.string "source", default: "SensorML"

    # Units
    # t.string "name"
    # t.string "abbreviation"
    # t.datetime "created_at", null: false
    # t.datetime "updated_at", null: false
    # t.integer "id_num"
    # t.string "unit_type"
    # t.string "source"

    return var_fields
  end


  def self.tmp_dir
    return "/tmp/bulk_downloads"
  end


  def self.processing_dir
    return "#{BulkDownload.tmp_dir}/processing"
  end

  def self.bulk_data_bytes_used
    # Total size of all bulk data packages (Includes temporary files):
    size_in_bytes = Dir["#{BulkDownload.tmp_dir}/**/*"].select { |f| File.file?(f) }.sum { |f| File.size(f) }
  end



end
