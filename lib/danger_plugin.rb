require 'oga'

module Danger

  class DangerStaticAnalyzerComments < Plugin
    LINT_SEVERITY_LEVELS = ["Warning", "Error", "Fatal"]
    CHECKSTYLE_SEVERITY_LEVELS = ["ignore", "info", "warning", "error"]

    attr_accessor :android_lint_report_file
    attr_accessor :checkstyle_report_file

    def run
      android_lint
      checkstyle
    end

    def android_lint
      unless File.exists?(@android_lint_report_file)
        fail("Lint report not found at `#{@android_lint_report_file}`.")
      end

      file = File.open(@android_lint_report_file)
      report = Oga.parse_xml(file)
      issues = report.xpath('//issue')
      send_android_lint_inline_comment(issues)
    end

    def checkstyle
      unless File.exists?(checkstyle_report_file)
        fail("Checkstyle report not found at `#{checkstyle_report_file}`.")
      end

      file = File.open(checkstyle_report_file)
      report = Oga.parse_xml(file)
      files = report.xpath('/checkstyle/file')
      send_checkstyle_inline_comment(files)
    end

    def send_checkstyle_inline_comment(files)
      files.each do |file|
        filename = file.get('name').gsub(current_dir, "")
        errors = file.xpath('error')
        errors.each do |error|
          next unless (target_files.include? filename)
          line = (error.get('line') || "0").to_i
          warn(error.get('message'), file: filename, line: line)
        end
      end
    end

    def send_android_lint_inline_comment(issues)
      LINT_SEVERITY_LEVELS.reverse.each do |level|
        filtered = issues.select {|issue| issue.get("severity") == level}
        next if filtered.empty?
        filtered.each do |r|
          location = r.xpath('location').first
          filename = location.get('file').gsub(current_dir, "")
          next unless (target_files.include? filename)
          line = (location.get('line') || "0").to_i
          send(level === "Warning" ? "warn" : "fail", r.get('message'), file: filename, line: line)
        end
      end
    end

    def target_files
      (git.modified_files - git.deleted_files) + git.added_files
    end

    def current_dir
      "#{Dir.pwd}/"
    end
  end
end