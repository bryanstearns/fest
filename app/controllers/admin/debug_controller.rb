require 'pp'

module Admin
  class DebugController < ApplicationController
    before_filter :authenticate_admin!

    # get /admin/env
    def env
      lines = ["--- ENV ---"] +
        ENV.map {|k, v| "#{k} = #{v}" } +
        ["", "--- REQ ---"] +
        request.env.pretty_inspect.split("\n")[0..1000]
      render plain: lines.join("\r\n")
    end

    # get /admin/crash
    def crash
      raise "Manual 'crash' exception!"
    end

    # get /admin/ping
    def ping
      render plain: "pong"
    end
  end
end
