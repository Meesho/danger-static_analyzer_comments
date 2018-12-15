require 'oga'

module Danger

  # A Danger plugin which turns static analyzers' output into inline Github comments
  class DangerStaticAnalyzerComments < Plugin
    LINT_SEVERITY_LEVELS = ["Warning", "Error", "Fatal"]

    attr_accessor :lint_report_file

    def run
      lint()
    end

    def lint
      unless File.exists?(@lint_report_file)
        fail("Lint report not found at `#{@lint_report_file}`.")
      end

      file = File.open(@lint_report_file)
      report = Oga.parse_xml(file)
      issues = report.xpath('//issue')
      send_lint_inline_comment(issues)
    end


    # Send inline comment with danger's warn or fail method
    def send_lint_inline_comment(issues)
      target_files = (git.modified_files - git.deleted_files) + git.added_files
      print target_files.to_a
      dir = "#{Dir.pwd}/"
      LINT_SEVERITY_LEVELS.reverse.each do |level|
        filtered = issues.select {|issue| issue.get("severity") == level}
        next if filtered.empty?
        filtered.each do |r|
          location = r.xpath('location').first
          filename = location.get('file').gsub(dir, "")
          print "location: #{location}, file: #{location.get('file')}, filename: #{filename}"
          next unless (target_files.include? filename)
          print "target_files includes #{filename}"
          line = (location.get('line') || "0").to_i
          send(level === "Warning" ? "warn" : "fail", r.get('message'), file: filename, line: line)
        end
      end
    end
  end
end