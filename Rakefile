begin
  require 'ant'
rescue LoadError
  puts 'This Rakefile requires JRuby. Please use jruby -S rake.'
  exit 1
end


neighbor_mirah = File.expand_path '../mirah'

if File.exists?(neighbor_mirah)
  ENV['MIRAH_HOME'] ||= neighbor_mirah
end

if  ENV['MIRAH_HOME'] && File.exist?(ENV['MIRAH_HOME'] +'/lib/mirah.rb')
  $: << File.expand_path(ENV['MIRAH_HOME'] +'/lib')
end

require 'rake/clean'
require 'mirah/appengine_tasks'


if File.exist?('../bitescript/lib/bitescript.rb')
   $: << File.expand_path('../bitescript/lib/')
end

MIRAH_HOME = ENV['MIRAH_HOME'] ? ENV['MIRAH_HOME'] : Gem.find_files('mirah').first.sub(/lib\/mirah.rb/,'')
 
MODEL_SRC_JAR =  File.join(MIRAH_HOME, 'examples', 'appengine', 'war',
                                 'WEB-INF', 'lib', 'dubydatastore.jar')

def mirahc *files
  p files
  if files[-1].kind_of?(Hash)
    options = files.pop
  else
    options = {}
  end
  source_dir = options.fetch(:dir, Mirah.source_path)
  dest = File.expand_path(options.fetch(:dest, Mirah.dest_path))
  files = files.map {|f| f.sub(/^#{source_dir}\//, '')}
  flags = options.fetch(:options, Mirah.compiler_options)
  args = ['-d', dest, *flags] + files
  chdir(source_dir) do
    cmd = "mirahc #{args.join ' '}"
    puts cmd
    Mirah.compile(*args)
    #Mirah.reset
  end
  generate_build_properties
end


OUTDIR = 'WEB-INF/classes'

def class_files_for files
  files.map do |f|
    explode = f.split('/')[1..-1]
    explode.last.gsub!(/(^[a-z]|_[a-z])/) {|m|m.sub('_','').upcase}
    explode.last.sub! /\.(duby|java|mirah)$/, '.class'
    OUTDIR + '/' + explode.join('/')
  end
end

MODEL_JAR = "WEB-INF/lib/dubydatastore.jar"

LIB_MIRAH_SRC = Dir["lib/**/*.{duby,mirah}"]
LIB_JAVA_SRC  = Dir["lib/**/*.java"]
LIB_SRC = LIB_MIRAH_SRC + LIB_JAVA_SRC
LIB_CLASSES = class_files_for LIB_SRC

STDLIB_CLASSES= LIB_CLASSES.select{|l|l.include? 'stdlib'}

CLASSPATH = [AppEngine::Rake::SERVLET, AppEngine::SDK::API_JAR].join(":")

Mirah.dest_paths << OUTDIR
Mirah.source_paths << 'lib'
Mirah.source_paths << 'app'
Mirah.compiler_options << '--classpath' << [File.expand_path(OUTDIR), *FileList["WEB-INF/lib/*.jar"].map{|f|File.expand_path(f)}].join(':') + ':' + CLASSPATH

directory OUTDIR
CLEAN.include(OUTDIR)

CLOBBER.include("WEB-INF/lib/dubious.jar", 'WEB-INF/appengine-generated')


APP_SRC = Dir["app/**/{*.duby,*.mirah}"]
APP_CLASSES = class_files_for APP_SRC
APP_CONTROLLER_CLASSES = APP_CLASSES.select {|app| app.include? '/models' }

(APP_CLASSES+LIB_CLASSES).zip(APP_SRC+LIB_SRC).each do |klass,src|
  file klass => src
end

TEMPLATES = Dir["app/views/**/*.erb"]
TEMPLATES.each do |klass|
  file klass => APP_CONTROLLER_CLASSES
end


# simplest automatic dependency resoltuion

filemap = {}
classmap = {}

APP_SRC.each { |file|
  name = File.basename(file)
  name = name.split('_').map{ |f| f.capitalize }.join('').split('.')[0]
  dest_name = name+'.class'
  #puts name
  compiled = OUTDIR + '/' + File.dirname(file).gsub('app/', '') + '/' + dest_name
  filemap[name] = { :src => file, :dest => compiled }
  classmap[compiled] = { :src => file, :class => name }
}

dependencies = {}

APP_CLASSES.each { |f|
  #puts f
  #p classmap[f]
  
  dependencies[f] = {}
  
  if (!classmap[f])
    warn "WARNING! info for #{f} not found"
    exit
  end  
  if f.include? 'html.erb'
    next
  end
  File.open(classmap[f][:src]).each { |line|
    line.scan(/[A-Z][A-Za-z0-9]*/).each { |klass|
      if (src = filemap[klass]) && (klass != classmap[f][:class])
        if !dependencies[f][src[:dest]]
          if f.include?("TestController")
            puts f + " depends on " + src[:dest]
          end
          dependencies[f][src[:dest]] = true
          #p [f, src[:dest]]
          #file f, src[:dest]#dependencies[f].keys
        end
      end
    }    
  }
  file f => dependencies[f].keys
}








appengine_app :app, 'app', '' => APP_CLASSES+LIB_CLASSES

#there is an upload task in appengine_tasks, but I couldn't get it to work
desc "publish to appengine"
task :publish => 'compile:app' do
  sh "appcfg.sh update ."
end

namespace :compile do
  task :app => APP_CLASSES

  task :java => OUTDIR do
    ant.javac :srcdir => 'lib', :destdir => OUTDIR, :classpath => CLASSPATH
  end

end

desc "compile app"
task :compile => 'compile:app'

desc "run development server"
task :server

task :default => :server

def generate_build_properties
  prop_file = "config/build.properties"
  File.open(prop_file, 'w') do |f| 
    f.write <<-EOF
time=#{Time.now.to_i*1000}
    EOF
  end
end