module FlashMessagesHelper

  def flash_to_headers
    return unless request.xhr?

    type, message = flash_message

    unless type.nil?
      response.headers['X-Message'] = message.encode("ISO-8859-1")
      response.headers["X-Message-Type"] = type.to_s
      flash.discard
    end
  end


  def flash_message
    [:error, :warning, :notice, :success].each do |type|
      return [type, flash[type]] unless flash[type].blank?
    end
    nil
  end

end