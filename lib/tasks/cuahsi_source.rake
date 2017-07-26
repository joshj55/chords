require 'task_helpers/cuahsi_helper'
include CuahsiHelper

namespace :db do
  desc "test adding source to hydroserver"
  task :cuahsi_source => :environment do |task, args|

  	data = Profile.create_cuahsi_source
    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/sources"

    CuahsiHelper.send_request(uri_path, data)
    
  end
end
