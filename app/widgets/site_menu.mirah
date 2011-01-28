/*
usage:

    SiteMenu.new(params).
      item('Dashboard', :index).
      item('Users', :users).
        subitem('Stories', 'users/stories').parent.
      item('Features', :features).to_s
*/


import ext.*
import java.util.ArrayList

class SiteMenu
  def initialize(e:RequestEvent)
    @e = e
    @root = MenuItem.new(self)
  end
  
  def e
    @e
  end
  
  def root
    @root
  end

  def item(name:String, link:String)
    @root.subitem(name, link)
  end
  
  def to_s
    @root.children_html
  end
  
  def toString
    to_s
  end
end

  class MenuItem
    def initialize(root:SiteMenu)
      @root = root
    end
    
    def parent(p:MenuItem)
      @parent = p
      self
    end
    
    def parent()
      @parent
    end
    
    def name(n:String)
      @name = n
      self
    end 
    
    def name
      @name
    end
    
    def link(l:String)
      @link = l
      
      self
    end
    
    def url
      unless @url      
        @url = @root.e.link_to(@link)
      end
      @url  
    end
    
    def item(name:String, link:String)
      parent.subitem(name, link)
    end
    
    def subitem(name:String, link:String)
      add MenuItem.new(@root).
        name(name).
        link(link)
    end
    
    def add(i:MenuItem)
      unless @children
        @children = ArrayList.new()
      end      
      @children.add(i.parent(self))
      i
    end
    
    def children
      @children
    end
    
    def children_html
      html = ''
      if children
        children.each { |_ch|
          child = MenuItem(_ch)
          html += child.html
        }
      end
      '<ul>'+html+'</ul>'
    end
    
    def html
      li = Element.new(:li)
      li.append_child(anchor)
      
      if active?
        #puts "TREFA"
        li.class(:active)
      end
      
      if @children
        li.add(children_html)
      end
      li.to_s
    end
    
    def active? 
      if url.split('/').length > 3
        @root.e.request.getRequestURI.endsWith(url.split('/', 4)[3])
      else
         @root.e.request.getRequestURI.equals('/')
      end
    end
    
    def anchor
      Element.a.href(url).html(name)
    end
    
    def to_s
      @root.to_s
    end
    
    def toString
      to_s
    end
    
  end