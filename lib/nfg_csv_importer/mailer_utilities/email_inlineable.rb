# Inline emails via `premailer-rails`
#
# We follow DMS's process of doing format
# and inlining manually.
#
# By default, all mailers that inherit from ApplicationMailer (or NfgMailer) include EmailInlineable
#
# Usage:
# 1. Add `skip_premailer: true` to `mail()` args
# 2. Add / replace  ` do |format| format.html { inlined_html } end` to the end of `mail()`
#
# Example:
# class MyMailer < ApplicationMailer
#   include EmailInlineable
#   def my_email
#     mail(
#      to: 'whoever@exapmle.com',
#      skip_premailer: true
#     ) do |format|
#       format.html { inlined_html }
#   end
# end

module NfgCsvImporter
  module MailerUtilities
    module EmailInlineable
      def inlined_html
        Premailer::Rails::CustomizedPremailer.new(html).to_inline_css
      end

      def html
        @html ||= render_to_string(path)
      end

      def path
        @path ||= "#{self.controller_path}/#{self.action_name}"
      end
    end
  end
end