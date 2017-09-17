module TestHelpers

  def body
    JSON.parse(last_response.body)
  end

end
