import dubious.*
import models.*

import java.util.regex.*
import java.util.ArrayList

import java.lang.reflect.*

import org.apache.commons.codec.binary.*

import com.google.appengine.api.users.UserService
import com.google.appengine.api.users.UserServiceFactory

import javax.mail.Message
import javax.mail.MessagingException
import javax.mail.Session
import javax.mail.Transport
import javax.mail.internet.AddressException
import javax.mail.internet.InternetAddress
import javax.mail.internet.MimeMessage

import javax.activation.DataHandler;
import javax.mail.Multipart;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMultipart;

import com.google.appengine.ext.mirah.db.*
import javax.servlet.ServletConfig
import javax.servlet.http.*
import java.util.regex.Pattern
import java.util.Arrays
import java.util.HashMap
import dubious.Params
import dubious.FormHelper
import java.io.File
import java.net.URI

import java.util.Properties





class MyController < HttpServlet

  def index; returns String
    raise "#{self} needs to implement index action."
    ''
  end

  
  def params
    @params
  end
  
  def params=(params:RequestEvent)
    @params = params
  end
  
  def request
    params.request
  end
  
  def respond(data:String)
    params.respond_string(data)
  end
  
  def respond_json(json:String); returns void
    params.respond_json(json)
  end  
  
  def redirect_to(where:String)
    #if @action == null || where != @action
    #puts "WANT TO REDIRECT TO "+where
      params.redirect_to where
    #end
  end  
  
  def redirect(where:String)
    params.redirect_to where
  end  
  
  def link(where:String)
    params.link_to(where)
  end
  
  def link(where:int)
    params.link_to("#{where}")
  end

  def link(where:long)
    params.link_to("#{where}")
  end
  
  # ------- flash -------
  
  def session
    params.request.getSession()
  end  
  
  def flash(message:String)
    session.setAttribute(:flash, message)
  end  
  
  def flash():String
    f = session.getAttribute(:flash) 
    session.setAttribute(:flash, null) 
    String.valueOf(f)
  end
  
  def flash?
    session.getAttribute(:flash) != null
  end    

  def flash_html
    if flash?
      '<div class="flash">'+flash+'</div>'
    else
      ''
    end
  end
  
  
  
  # ------- execution -------
  
  def before_action; returns void; end
  def after_action; returns void; end
  
  def action=(a:String)
    @action = a
  end
  
  def action
    @action
  end  
  
  def go(c:MyController)
    c._execute(params)
    params.content
  end
  
  def nest(c:MyController)
    @nested = c
    e = params.nest
    c.parent(self).
      _execute(e)
    e.content
  end
  
  def parent(c:MyController)
    @parent = c
    self
  end
  
  def parent
    @parent
  end
  
  def execute(e:RequestEvent):void
    begin
      _execute(e)
    rescue Exception => ex
      handle_exception(ex)
    end
    return
  end
  
  def eat()
    params.eat()
    unless @action_set
      self.action = params.peek
    end
  end
      
  def _execute(e:RequestEvent):void
    @nested = MyController(nil)
    self.action = e.peek
    self.params = e
    
    #puts "ACTION: #{action}"
    
    before_action()
    not_found = true
    getClass().getDeclaredMethods.each { |method|
      if method.getName().equals(action)
        not_found = false
        e.action #remove the action from url
        me = self
        @action_set = true
        content = String.valueOf(method.invoke(me, null))
      end
    }
    if not_found
      content = String.valueOf(index())
    end      
    unless content.equals('null')
      e.content = content
    end      
    after_action()   
    return
  end
  
  def handle_exception(ex:Throwable)
    name = ex.getClass.getName
    
    if name.endsWith(:ClientException)
      if params.ajax?
        reply_error(ex.getMessage)
        null
        return
      end
    end
    
    if name.endsWith(:EarlyResponse)
      self.params = EarlyResponse(ex).request_event
      return
    end
      
    if name.endsWith(:InvocationTargetException)
      handle_exception(ex.getCause)
      return
    end
    
    display_exception(ex)
    return
  end
  
  
  def display_exception(ex:Throwable)
    if Application.development?
      private_exception(ex)
    else
      public_exception(ex)
    end
  end
  
  # application controller should override this one
  def private_exception(ex:Throwable):void
    out = ShowException.new.pretty(request, ex)
    #puts out
    params.content = out
  end
  
  def public_exception(ex:Throwable):void
    exception_email(
        ex.getMessage, 
        ShowException.new.pretty(request, ex)
      )
    params.content = show_500
  end
  
  def silent_exception(ex:Throwable):void
    exception_email(
        ex.getMessage, 
        ShowException.new.pretty(request, ex)
      )
  end
  
  def show_500:String
    'We\'re sorry, but something went wrong.'
  end
  
  

  def doGet(request, response):void
    #puts request.getContentType
    self.params = RequestEvent.new(request, response)
    execute(params)      
    params.output
  end 
  
  def doPost(request, response):void
    if request.getContentType.equals("application/coffee-pot-command")
      response.setStatus(418, "I'm a teapot")
      nil
    else
      doGet(request, response)
      nil
    end
  end     
  
  def reply(kind:String, message:String)
    respond "{event:'#{kind}', data:'#{message}'}"
    true
  end
  
  def reply_raw(kind:String, message:String)
    respond "{event:'#{kind}', data:#{message}}"
    true
  end
  
  def reply_error(message:String)
    reply(:error, message)
  end  
  
  def reply_ok(message:String)
    reply(:ok, message)
    reply(@action+'_ok', '')
  end     

  def exception_email(subject:String, message:String)
    props = Properties.new()
    session = Session.getDefaultInstance(props, null)

    from = Application.config('exceptions.send_from')
    Application.config('exceptions.send_to').split(',').each { |to|    
      
      msg = MimeMessage.new(session)
      msg.setFrom(InternetAddress.new(from, "Your Server"))
      msg.addRecipient(
        Message.RecipientType.TO,
        InternetAddress.new(to, "Best admin in the world")
      )
      msg.setSubject(subject || '(no subject)')
      msg.setText(message)
        
        
      htmlBody = message
        
      mp = MimeMultipart.new
        
      htmlPart = MimeBodyPart.new()
      htmlPart.setContent(htmlBody, "text/html");
      mp.addBodyPart(htmlPart);
      
      msg.setContent(mp)
      Transport.send(msg)      
    }
    null
  end      
  

  
  
  
  
  # ActionView::Helpers::TagHelper
  #
  # cdata_section
  # escape_once

  # tag() and content_tag() are now the same method
  # pass nil (instead of an empty string) to get tag()
  def _tag(name:String, value:String, options:HashMap,
          open:boolean, escape:boolean)
    sb = StringBuilder.new("<#{name}")
    keys = options.keySet.toArray; Arrays.sort(keys)
    keys.each { |k| sb.append(" #{k}=\"#{options.get(k)}\"") }
    if value.nil?
      sb.append(open ? ">" : " />")
    else
      sb.append(">#{escape ? h(value) : value}</#{name}>")
    end
    sb.toString
  end

  def tag(name:String, options:HashMap,
          open:boolean, escape:boolean)
    _tag(name, nil, options, open, escape)
  end

  def tag(name:String, options:HashMap, open:boolean)
    _tag(name, nil, options, open, true)
  end

  def tag(name:String, options:HashMap)
    _tag(name, nil, options, false, true)
  end

  def tag(name:String)
    _tag(name, nil, HashMap.new, false, true)
  end

  def content_tag(name:String, value:String, options:HashMap,
                  open:boolean, escape:boolean)
    _tag(name, value, options, open, escape)
  end

  def content_tag(name:String, value:String, options:HashMap, open:boolean)
    _tag(name, value, options, open, true)
  end

  def content_tag(name:String, value:String, options:HashMap)
    _tag(name, value, options, false, true)
  end

  def content_tag(name:String, value:String)
    _tag(name, value, HashMap.new, false, true)
  end

  def content_tag(name:String)
    _tag(name, "", HashMap.new, false, true)
  end  
  

# "<a #{href_attr}#{tag_options}>#{name || url}</a>".html_safe

  # ActionView::Helpers::AssetTagHelper
  #
  # cache_asset_timestamps
  # cache_asset_timestamps=
  # auto_discovery_link_tag
  # path_to_image
  # path_to_javascript
  # path_to_stylesheet
  # register_javascript_expansion
  # register_javascript_include_default
  # register_stylesheet_expansion

  # always use AssetTimestampsCache
  def add_asset_timestamp(source:String)
    @asset_timestamps_cache.get(source)
  end

  def image_path(source:String)
    source = "/images/#{source}" unless source.startsWith('/')
    add_asset_timestamp(source)
  end

  def javascript_path(source:String)
    source += ".js" unless source.endsWith(".js")
    source = "/javascripts/#{source}" unless source.startsWith('/')
    add_asset_timestamp(source)
  end

  def stylesheet_path(source:String)
    source += ".css" unless source.endsWith(".css")
    source = "/stylesheets/#{source}" unless source.startsWith('/')
    add_asset_timestamp(source)
  end

  def image_tag(source:String, options:HashMap)
    source = source.startsWith('http') ? source : image_path(source)
    options.put("src", source)
    options.put("alt", "") unless options.containsKey("alt")
    if options.containsKey("size") &&
        String(options.get("size")).matches("\\d+x\\d+")
      values = String(options.get("size")).split("x")
      options.put("width", values[0])
      options.put("height", values[1])
      options.remove("size") 
    end
    tag("img", options)
  end

  def image_tag(source:String)
    image_tag(source, HashMap.new)
  end

  def javascript_include_tag(text:String)
    text = javascript_path(text) unless text.startsWith("http")
    options = HashMap.new
    options.put("src", text)
    options.put("type", "text/javascript")
    content_tag("script", "", options)
  end

  def stylesheet_link_tag(text:String)
    text = stylesheet_path(text) unless text.startsWith("http")
    options = HashMap.new
    options.put("href", text)
    options.put("rel", "stylesheet")
    options.put("type", "text/css")
    options.put("media", "screen")
    tag("link", options)
  end

  # init the servlet

  def init(config:ServletConfig)
    @asset_timestamps_cache = AssetTimestampsCache.new
  end

  # escape special characters

  def self.initialize; returns :void
    @escape_pattern = Pattern.compile("[<>&'\"]")
    @escaped = HashMap.new
    @escaped.put("<", "&lt;")
    @escaped.put(">", "&gt;")
    @escaped.put("&", "&amp;")
    @escaped.put("\"", "&quot;")
    @escaped.put("'", "&#39;")
  end

  def self.html_escape(text:String)
    return "" unless text
    matcher = @escape_pattern.matcher(text)
    buffer = StringBuffer.new
    while matcher.find
      replacement = String(@escaped.get(matcher.group))
      matcher.appendReplacement(buffer, replacement)
    end
    matcher.appendTail(buffer)
    return buffer.toString
  end

  def self.html_escape(o:Object)
    return "" unless o
    html_escape(o.toString)
  end

  def h(text:String)
    MyController.html_escape(text)
  end

  def h(o:Object)
    MyController.html_escape(o)
  end  
  
end







