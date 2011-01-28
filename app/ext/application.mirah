
import com.google.appengine.api.utils.SystemProperty
import java.util.Properties

import java.io.FileInputStream


class Application
  def self.id
    SystemProperty.applicationId.get()
  end
  
  def self.version
    SystemProperty.applicationVersion.get()
  end
  
  def self.instance_id
    SystemProperty.instanceReplicaId.get()
  end
  
  def self.development?
    SystemProperty.environment.value == SystemProperty.Environment.Value.Development
  end
  
  def self.production?
    SystemProperty.environment.value == SystemProperty.Environment.Value.Production
  end  
  
  def self.config(identifier:String)
    info = identifier.split('\\.',2);
    file = info[0]
    record = info[1]
    props = Properties.new
    begin
      props.load(FileInputStream.new("config/#{file}.properties"))
      out = props.getProperty(record)
    rescue
      out = 'unset'
    end
    out
  end  
  
end

