# frozen_string_literal: true

class FileExports::CsvWorker < FileExports::Worker
  def file_name(_options)
    "export-#{ Time.current.strftime('%Y-%m-%d') }.csv"
  end

  def file_content_type(_options)
    'text/csv'
  end

  def file_content(options)
    CSV.generate(headers: true) do |csv|
      csv_contents csv, options
    end
  end

  def csv_content(_csv, *_options)
    raise NotImplementedError
  end
end
