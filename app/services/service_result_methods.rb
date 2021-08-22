module ServiceResultMethods
  def build_result(success: , status: , message: nil, data: {})
    Hashie::Mash.new(
      success?: success,
      failure?: !success,
      status: status,
      message: message,
      data: data
    )
  end

  def success_result(status: :success, message: nil, data: {})
    build_result success: true, status: status, message: message, data: data
  end

  def error_result(status: :error, message: nil, data: {})
    build_result success: false, status: status, message: message, data: data
  end
end
