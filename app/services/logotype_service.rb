class LogotypeService
  class MissingFile < StandardError; end
  class BadExtension < StandardError; end

  MISSING_IMAGE_EXT = '.png'
  MISSING_IMAGE_NAME = 'no-image.png'
  MISSING_IMAGE_PATH = Rails.root.join('app', 'assets', 'images')
  MISSING_PROCESSED_IMAGE_SUBDIR = 'assets/images/no-image'
  MISSING_PROCESSED_IMAGE_PATH = Rails.root.join('public', MISSING_PROCESSED_IMAGE_SUBDIR)

  ACCEPTED_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.gif', '.bmp']

  # if you update the sizes bellow,
  # run task: "rake assets:generate_no_image_formats" and commit files
  SIZES = {
    iconic:     {w:   24, h:  24},
    tiny:       {w:  100, h: 100},
    thumb:      {w:  280, h: 280},
    small:      {w:  280},
    thumb_normalize: {w:  540, h: 448},
    normalize:  {w:  540},
    big:        {w:  720},
    huge:       {w:  960},
    original:   {w: 1140}
  }
  DEFAULT_SIZE = :small

  def initialize
    @aws_creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_KEY'])
    @aws_s3_client = Aws::S3::Client.new(region: ENV['AWS_S3_REGION'], credentials: @aws_creds)
    @aws_s3_bucket = Aws::S3::Bucket.new(ENV['AWS_S3_BUCKET'], client: @aws_s3_client)
  end

  def process_image(original_filename, path)
    # check if the file extension is right
    raise BadExtension unless ACCEPTED_EXTENSIONS.include? File.extname(original_filename).downcase

    # convert the file to PNG, Magick automatically converts to the extension
    # of the ouput file
    magick = Magick::Image.read(path).first

    [].tap do |processed_images|
      SIZES.each_pair do |size_name, size_dimensions|
        temp = Tempfile.new(['img', size_name.to_s, '.png'])
        temp_img = if size_dimensions.key? :h
                     if magick.columns > magick.rows
                       x = 0
                       y = ((size_dimensions[:h] - magick.rows * size_dimensions[:w].to_f / magick.columns.to_f) / 2).to_i
                     else
                       y = 0
                       x = ((size_dimensions[:w] - magick.columns * size_dimensions[:h].to_f / magick.rows.to_f) / 2).to_i
                     end
                     magick.resize_to_fit(size_dimensions[:w], size_dimensions[:h]).extent(size_dimensions[:w], size_dimensions[:h], -x, -y)
                   else
                     magick.scale(size_dimensions[:w].to_f / magick.columns.to_f)
                   end
        temp_img.write temp.path

        processed_images << [temp, size_name]
      end
    end
  end

  def upload client_id, file
    # check if file is missing
    raise MissingFile if file.blank?

    process_image(file.original_filename, file.path).each do |image|
      # uploaded the PNG file to S3
      aws_s3_object(client_id, image[1]).delete
      aws_s3_object(client_id, image[1]).upload_file(image[0].path, acl: 'public-read', content_type: 'image/png')

      # clean up
      image[0].unlink
    end

    true
  rescue Aws::S3::MultipartUploadError => e
    [false, I18n.t('errors.aws.s3.multipart_upload_error', errors: e.errors)]
  rescue BadExtension
    [false, I18n.t('errors.logotype.bad_extension', extensions: ACCEPTED_EXTENSIONS.join(', '))]
  rescue MissingFile
    [false, I18n.t('errors.logotype.missing_file')]
  rescue
    [false, I18n.t('errors.logotype.unknown_error_while_uploading')]
  end

  def delete client_id
    SIZES.each do |size_name|
      aws_s3_object(client_id, size_name[0]).delete
    end

    true
  rescue
    [false, I18n.t('errors.logotype.unknown_error_while_deleting')]
  end

  def image client_id, size_name
    size_name = DEFAULT_SIZE unless SIZES.key?size_name

    url = begin
            if exists?(client_id, size_name)
              aws_s3_object(client_id, size_name).public_url
            else
              ActionController::Base.helpers.asset_path("#{MISSING_PROCESSED_IMAGE_PATH}/#{size_name}#{MISSING_IMAGE_EXT}")
            end
          rescue Aws::S3::Errors::Forbidden
            ActionController::Base.helpers.asset_path("#{MISSING_PROCESSED_IMAGE_PATH}/#{size_name}#{MISSING_IMAGE_EXT}")
          end

    file = open(url)
    blob = file.read
    file.close

    blob
  end

  def exists? client_id, size_name = DEFAULT_SIZE
    size_name = DEFAULT_SIZE unless SIZES.key?size_name

    aws_s3_object(client_id, size_name).exists?
  rescue Aws::S3::Errors::Forbidden
    false
  end

  def url client_id, size_name
    size_name = DEFAULT_SIZE unless SIZES.key?size_name

    if exists?(client_id, size_name)
      aws_s3_object(client_id, size_name).public_url
    else
      ActionController::Base.helpers.asset_path("#{MISSING_PROCESSED_IMAGE_SUBDIR}/#{size_name}#{MISSING_IMAGE_EXT}")
    end
  rescue Aws::S3::Errors::Forbidden
    ActionController::Base.helpers.asset_path("#{MISSING_PROCESSED_IMAGE_SUBDIR}/#{size_name}#{MISSING_IMAGE_EXT}")
  end

  private

  def aws_s3_object client_id, size_name
    @aws_s3_bucket.object("#{ENV['AWS_S3_BUCKET_DIR_LOGOTYPES']}/#{client_id}/#{size_name}")
  end
end
