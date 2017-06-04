namespace 'assets' do

  desc "generate all formats of missing image asset"
  task :generate_no_image_formats => :environment do

    logotype_service = LogotypeService.new

    no_image_path = "#{LogotypeService::MISSING_IMAGE_PATH}/#{LogotypeService::MISSING_IMAGE_NAME}"
    file_ext = File.extname(no_image_path).downcase
    images = logotype_service.process_image(LogotypeService::MISSING_IMAGE_NAME, no_image_path)

    images.each do |img|
      rm "#{LogotypeService::MISSING_PROCESSED_IMAGE_PATH}/#{img[1]}#{file_ext}"
      cp img[0], "#{LogotypeService::MISSING_PROCESSED_IMAGE_PATH}/#{img[1]}#{file_ext}"
      img[0].unlink
    end

  end

end