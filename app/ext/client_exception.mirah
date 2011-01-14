import java.lang.Exception

class ClientException < Exception
  def initialize(message:String)
    @message = message
  end
  
  def message
    @message
  end
  
  def getMessage
    message
  end
end