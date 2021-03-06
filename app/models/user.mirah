import com.google.appengine.ext.mirah.db.*
import com.google.appengine.api.datastore.*
import java.util.regex.*
import java.util.*

import java.math.BigInteger
import java.security.SecureRandom
import org.apache.commons.codec.binary.Base64

import java.security.MessageDigest
import dubious.*
import ext.*


class User < Model
  property :name, String
  property :email, String
  property :password_hash, String
  property :salt, String
  property :naughty, Integer
  property :locked, Boolean
  
  def lock(_yes:boolean)
    puts "LOCK CUSTOMER #{_yes}"
    this = self
    yes = _yes
    Model.transaction do
      c = User.get(this.id)
      if yes
        if c.locked
          raise 'User is already locked.'
        end
      else 
        if c.locked
          null
        else
          raise 'User is already unlocked.'
          null
        end
      end
      c.locked = yes
      this.locked = yes
      c.save
    end      
  end
  
  def lock(); lock(true); end  
  def unlock; lock(false); end 
  
  def locked?
    locked
  end
  
  def id 
    key.getId
  end
  
  def naughty!
    self.naughty = naughty + 1
    save
  end
  
  def url_id    
    if key != null
      String.valueOf(key.getId)
    else
      'new'
    end
  end
 
  def self.register(email:String, password:String)
    user = new
    user.email = email
    user.password = password
    user 
  end  
  
  def self.register_quick(name:String, email:String)
    user = new
    user.name = name
    user.email = email
    user.password = user.generate_password
    user 
  end
  
  def self.login(email:String, pass:String)    
    if user = all.email(email).first
      if user.password_hash.equals(user.hash(pass, user.salt))
        user
      else
        raise ClientException.new('Incorrect Email or Password.')
      end
    else
      raise ClientException.new('Incorrect Email or Password.')
    end
  end
  
  def self.blank
    instance = new
    instance
  end
  
  def password=(pass:String)
    @new_password = pass
    self.salt = generate_salt
    self.password_hash = hash(pass, salt)
    null
  end
  
  def generate_password; returns String
    @generated_password = User.generate_password(8)
    @generated_password
  end
  
  def self.generate_password(length:int)
    bits = 5*length # 1 password character = 5 bits 
    BigInteger.
      new(bits, SecureRandom.new). # generate a random number 
      setBit(bits-1). #make sure the random number is always <length> chars long
      toString(32) # convert to alphanumeric password like i3ue2mr4
  end
  
  def generated_password
    @generated_password
  end
  
  def generate_salt
    BigInteger.new(256, SecureRandom.new).toString(64)
  end  

  def hash(password:String, salt:String); returns String
    digest = MessageDigest.getInstance("SHA-256")
    digest.reset()
    digest.update(salt.getBytes())
    return Base64.encodeBase64String(digest.digest(password.getBytes("UTF-8")))
  end
  
  def validate_email
    email.matches('[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?')
  end
  
  def validate_name
    (name.length > 0)
  end
  
  def validate_password
    @new_password == null || (@new_password.length >= 6)
  end
  
  def validate(); returns void
    validate_email || (raise ClientException.new('The value entered is not a valid email address.'))
    validate_password || (raise ClientException.new('Password is a required field.'))
  end  
  
  def save
    validate()
    super() || raise('I was unable to save myself!')
  end


  # for testing
  
  def self.michal
    c = User.new
    c.name = 'Michal Hantl'
    c.password = 'michal'
    c.email = 'michal.hantl@gmail.com'
    c.save
    c
  end
  
  def self.vojta
    c = User.new
    c.name = 'Vojtěch Vrbka'
    c.password = 'secret'
    c.email = 'vojtech.vrbka@gmail.com'
    c.save
    c
  end
  
end



























