

import com.google.appengine.api.utils.SystemProperty

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
end

