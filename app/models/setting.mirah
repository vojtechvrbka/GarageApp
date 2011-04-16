import com.google.appengine.ext.mirah.db.*
import com.google.appengine.api.datastore.*;
import dubious.*
import ext.*
import java.util.*


class Setting < Model

  property :spritmonitor, Integer
  
  def id 
    key.getId
  end


end