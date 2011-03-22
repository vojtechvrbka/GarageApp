import dubious.*
import ext.*
import models.*
import java.util.regex.*
import java.util.ArrayList

import org.apache.commons.codec.binary.*

import com.google.appengine.api.users.UserService
import com.google.appengine.api.users.UserServiceFactory

import com.google.appengine.api.blobstore.BlobKey
import com.google.appengine.api.blobstore.BlobstoreService
import com.google.appengine.api.blobstore.BlobstoreServiceFactory


class AdminController < MyController 
  def index
    @page_content = ''
    main_erb
  end
  

  
  def login
    login_erb
  end
  
  def before_action
    @page_title = "MotoCash Admin"
    @userline = ''
    
    if request.getUserPrincipal() != null &&
       (UserServiceFactory.getUserService().isUserAdmin() || request.getUserPrincipal().getName.equals('webkseft@gmail.com'))
      logout = UserServiceFactory.getUserService().createLogoutURL(request.getRequestURI)
      @userline = request.getUserPrincipal().getName +
          ' | <a href="'+logout+'">Sign out</a>'
    else
      self.action = :login
    end
  end
  
  def_edb(main_erb, 'views/layouts/admin.html.erb')
  def_edb(login_erb, 'views/layouts/admin_login.html.erb')
end

