require 'logging'

module OmfCommon
  module DefaultLogging
    # Use global default logger from logging gem
    include Logging.globally

    Logging.appenders.stdout(
      'default_stdout',
      :layout => Logging.layouts.pattern(:date_pattern => '%F %T %z',
                                         :pattern => '[%d] %-5l %c: %m\n',
                                         :color_scheme => 'default'))
    Logging.logger.root.appenders = 'default_stdout'
    Logging.logger.root.level = :info

    # Alias logging method using default logger
    def info(*args, &block)
      logger.info(*args, &block)
    end

    # @see #info
    def debug(*args, &block)
      logger.debug(*args, &block)
    end

    # @see #info
    def error(*args, &block)
      logger.error(*args, &block)
    end

    # @see #info
    def fatal(*args, &block)
      logger.fatal(*args, &block)
    end

    # @see #info
    def warn(*args, &block)
      logger.warn(*args, &block)
    end

    # Log a warning message for deprecated methods
    def warn_deprecation(deprecated_name, *suggest_names)
      logger.warn "[DEPRECATION] '#{deprecated_name}' is deprecated. Please use '#{suggest_names.join(', ')}' instead."
    end

    def warn_removed(deprecated_name)
      define_method(deprecated_name) do |*args, &block|
        logger.warn "[DEPRECATION] '#{deprecated_name}' is deprecated and not supported. Please do not use it."
      end
    end
  end
end
