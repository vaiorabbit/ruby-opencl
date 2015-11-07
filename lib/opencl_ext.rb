# -*- coding: utf-8 -*-
require 'fiddle/import'
require_relative 'opencl'

# OpenCL 1.2 - Platform-dependent extensions

module OpenCL

  def self.import_ext_APPLE

    return false unless @@cl_import_done

  end

end
