# encoding: utf-8
require "uri"

module Mongoid #:nodoc
  class Config #:nodoc
    include Singleton

    attr_accessor \
      :allow_dynamic_fields,
      :reconnect_time,
      :parameterize_keys,
      :persist_in_safe_mode,
      :persist_types,
      :raise_not_found_error,
      :use_object_ids

    # Defaults the configuration options to true.
    def initialize
      @allow_dynamic_fields = true
      @parameterize_keys = true
      @persist_in_safe_mode = true
      @persist_types = true
      @raise_not_found_error = true
      @reconnect_time = 3
      @use_object_ids = false
    end

    # Sets the default time zone in which times are returned from the database. Often
    # you will want to set UTC. If you give a value which is not a valid key to
    # +ActiveSupport::TimeZone[]+, then an error will be raised.
    # If you give a blank value, or omit it entirely, then times will be returned in
    # the local time zone.
    #
    # Example:
    #
    # <tt>Config.time_zone = "UTC"</tt>
    #
    # Returns:
    #
    # The ActiveSupport::TimeZone object.
    def time_zone=(value)
      if value.nil?
        @time_zone = nil
      elsif ActiveSupport::TimeZone[value].nil?
        raise ArgumentError, "Unsupported time zone. Supported time zones are: #{ActiveSupport::TimeZone.all.map(&:name).join(" ")}."
      else
        @time_zone = ActiveSupport::TimeZone[value]
      end
    end

    # Returns the default time zone in which times are returns from the database, or if none has been set it will return
    # the local time zone.
    #
    # Example:
    #
    # <tt>Config.time_zone</tt>
    #
    # Returns:
    #
    # The ActiveSupport::TimeZone object.
    def time_zone
      @time_zone
    end

    # Sets the Mongo::DB master database to be used. If the object trying to be
    # set is not a valid +Mongo::DB+, then an error will be raised.
    #
    # Example:
    #
    # <tt>Config.master = Mongo::Connection.db("test")</tt>
    #
    # Returns:
    #
    # The Master DB instance.
    def master=(db)
      raise Errors::InvalidDatabase.new(db) unless db.kind_of?(Mongo::DB)
      @master = db
    end

    # Returns the master database, or if none has been set it will raise an
    # error.
    #
    # Example:
    #
    # <tt>Config.master</tt>
    #
    # Returns:
    #
    # The master +Mongo::DB+
    def master
      @master || (raise Errors::InvalidDatabase.new(nil))
    end

    alias :database :master
    alias :database= :master=

    # Sets the Mongo::DB slave databases to be used. If the objects trying to me
    # set are not valid +Mongo::DBs+, then an error will be raise.
    #
    # Example:
    #
    # <tt>Config.slaves = [ Mongo::Connection.db("test") ]</tt>
    #
    # Returns:
    #
    # The slaves DB instances.
    def slaves=(dbs)
      dbs.each { |db| raise Errors::InvalidDatabase.new(db) unless db.kind_of?(Mongo::DB) }
      @slaves = dbs
    end

    # Returns the slave databases, or if none has been set nil
    #
    # Example:
    #
    # <tt>Config.slaves</tt>
    #
    # Returns:
    #
    # The slave +Mongo::DBs+
    def slaves
      @slaves
    end

    # Confiure mongoid from a hash that was usually parsed out of yml.
    #
    # Example:
    #
    # <tt>Mongoid::Config.instance.from_hash({})</tt>
    def from_hash(settings)
      _master(settings)
      _slaves(settings)
      settings.except("database").each_pair do |name, value|
        send("#{name}=", value) if respond_to?(name)
      end
    end

    # Reset the configuration options to the defaults.
    #
    # Example:
    #
    # <tt>config.reset</tt>
    def reset
      @allow_dynamic_fields = true
      @parameterize_keys = true
      @persist_in_safe_mode = true
      @raise_not_found_error = true
      @reconnect_time = 3
      @use_object_ids = false
      @time_zone = nil
    end

    protected

    # Check if the database is valid and the correct version.
    #
    # Example:
    #
    # <tt>config.check_database!</tt>
    def check_database!(database)
      raise Errors::InvalidDatabase.new(database) unless database.kind_of?(Mongo::DB)
      version = database.connection.server_version
      raise Errors::UnsupportedVersion.new(version) if version < Mongoid::MONGODB_VERSION
    end

    # Get a Rails logger or stdout logger.
    #
    # Example:
    #
    # <tt>config.logger</tt>
    def logger
      defined?(Rails) ? Rails.logger : Logger.new($stdout)
    end

    # Get a master database from settings.
    #
    # Example:
    #
    # <tt>config._master({}, "test")</tt>
    def _master(settings)
      name = settings["database"]
      host = settings.delete("host") || "localhost"
      port = settings.delete("port") || 27017
      self.master = Mongo::Connection.new(host, port, :logger => logger).db(name)
    end

    # Get a bunch-o-slaves from settings and names.
    #
    # Example:
    #
    # <tt>config._slaves({}, "test")</tt>
    def _slaves(settings)
      name = settings["database"]
      self.slaves = []
      slaves = settings.delete("slaves")
      slaves.to_a.each do |slave|
        self.slaves << Mongo::Connection.new(
          slave["host"],
          slave["port"],
          :slave_ok => true
        ).db(name)
      end
    end
  end
end
