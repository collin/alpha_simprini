require 'rubygems'
require 'listen'
require 'bundler/setup'
require 'reel'
require 'rake-pipeline'

module Pathology
end

class Pathology::Engine < Rails::Engine
  def self.add_project(assetfile)
    Celluloid::Actor[:asset_change_server].add_project(assetfile)
  end

  initializer "pathology.asset_change_server" do
    Pathology::AssetChangeServer.supervise_as :asset_change_server
  end
end

class Pathology::AssetChangeServer
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  def add_project(assetfile)
    project = Rake::Pipeline::Project.new(assetfile)
    project.pipelines.map(&:inputs).each do |map|
      next unless map.key?("src")
      path = "./src/#{map["src"].gsub!('*', '')}"
      path.gsub! "//", "/"
    end

    listener = Listen.to().change do |modified, added, removed|
      modified.each do |path|      
        changed(path)
      end
    end
    listener.start(false)
  end

  def changed(path)
    publish 'file_change', path
  end
end

class Pathology::DevChannel
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  include Celluloid::Instrumentation

  def initialize(socket)
    info "Streaming DevChannel updates to client #{socket}"
    @socket = socket
    subscribe('file_change', :notify_file_change)
  end

  def notify_file_change(topic, path)
    instrument :FileChange
    new_path = "tmp/outfile.js"
    project = Rake::Pipeline::Project.build do
      tmpdir "tmp"
      output "tmp"  

      input File.dirname(path) do
        match File.basename(path) do
          concat new_path
        end
      end
    end

    # client_path = new_path.gsub /.*lib\//, ''

    # @socket << JSON.dump({protocol: "loadScript", args: [client_path, File.read(new_path)]})
    end_instrument :FileChange
  rescue Reel::SocketError
    info "AssetChangeServer client disconnected"
    terminate
  end

  def instrument(id)
    @active ||= {}
    @active[id] = Time.new
  end

  def end_instrument(id)
    started_at = @active.delete(id)
    total = ((Time.new - started_at) * 1000.0).to_s
    info "[#{id}] #{total}ms"
  end
end

