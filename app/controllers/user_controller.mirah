import dubious.*
import ext.*
import models.*
import utils.*
import tasks.*
import java.util.regex.*
import java.util.ArrayList;

import org.apache.commons.codec.binary.*

import java.lang.reflect.InvocationTargetException

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import java.io.PrintWriter;
import java.io.StringWriter;

import com.google.appengine.ext.mirah.db.*


class UserController < SiteController

  def login
    if params.has(:email)      
      self.user = User.login(params[:email], params[:password])
      if params.has(:ajax)
        if user != null
          reply_raw :set_user, user_json
          reply_ok("Jste přihlášen(a).")
        else
          reply_error("Špatný email, nebo heslo.")
        end
        null
      else
        redirect_to '/'
        null
      end    
    end
    @page_content = login_erb
    main_erb
  end
  
  def login_ajax
    self.user = User.login(params[:email], params[:password])
    if params.has(:ajax)
      if user != null
        reply :set_user, user_json
        reply_ok("Jste přihlášen(a).")
      else
        reply_error("Špatný email, nebo heslo.")
      end
      null
    else
      redirect_to '/'
      null
    end
  end
  
  def logout
    session = request.getSession()
    session.setAttribute("user_id", null)
    redirect_to :index
  end
  
  def register
    name = params['name']
    email = params['email']
    pass = params['password']
    pass_again = params['password_again']
    
    if user = User.all.email(email).first
      reply_error 'Tento email je již registrován.'
    else
      pass.equals(pass_again) ||
        (raise ClientException.new('Heslo a jeho ověření si neodpovídají.'))
      c = User.register(name, email, pass)
      if c.save
       # Emailing.new(c).on_register.send
        session.setAttribute("user_id", Long.valueOf(c.id))
      end
      reply_ok 'Děkujeme za vaši přízeň.'
    end
  end  
    
  
  def_edb(login_erb, 'views/site/login.html.erb')
  def_edb(main_erb, 'views/layouts/site.html.erb')  
end










