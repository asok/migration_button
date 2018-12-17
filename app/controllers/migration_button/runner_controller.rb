# frozen_string_literal: true

class MigrationButton::RunnerController < ActionController::Base
  layout "migration_button/application"

  skip_before_action :verify_authenticity_token if respond_to?(:verify_authenticity_token)

  def index
    @page = page
  end

  def migrate
    @page = page { runner.migrate }

    render :index
  end

  def up
    @page = page { runner.run(:up, params[:version]) }

    render :index
  end

  def down
    @page = page { runner.run(:down, params[:version]) }

    render :index
  end

  def self.runner
    MigrationButton::Runner.new
  end

  def self.page(&blk)
    output = blk&.call

    Page.new(runner.migrations_status,
             output,
             MigrationButton::Middleware.last_request)
  end

  protected

  def runner
    @runner ||= self.class.runner
  end

  def page(&blk)
    self.class.page(&blk)
  end

  class Page
    attr_reader :migrations, :output, :last_request

    def initialize(migrations_status, output, last_request)
      @migrations = migrations_status.map do |(state, version, name)|
        Migration.new(state, version, name)
      end.sort_by(&:version).reverse

      @output = output
      @last_request = last_request
    end

    class Migration < Struct.new(:state, :version, :name)
      NO_FILE = '********** NO FILE **********'

      def runnable?
        name != NO_FILE
      end

      def down?
        state == "down"
      end

      def up?
        !down?
      end
    end
  end
end
