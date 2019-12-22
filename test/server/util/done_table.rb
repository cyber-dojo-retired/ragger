require_relative 'f2'

def done_table(log_stats, app_stats, test_stats)
  test_count    = log_stats[:test_count]
  failure_count = log_stats[:failure_count]
  error_count   = log_stats[:error_count]
  warning_count = log_stats[:warning_count]
  skip_count    = log_stats[:skip_count]
  test_duration = log_stats[:time].to_f

  app_coverage  = app_stats[:coverage].to_f
  test_coverage = test_stats[:coverage].to_f

  line_ratio = (test_stats[:line_count].to_f / app_stats[:line_count].to_f)
  hits_ratio = (app_stats[:hits_per_line].to_f / test_stats[:hits_per_line].to_f)

  [
    [ 'tests',                  test_count,     '!=',    0 ],
    [ 'failures',               failure_count,  '==',    0 ],
    [ 'errors',                 error_count,    '==',    0 ],
    [ 'warnings',               warning_count,  '==',    0 ],
    [ 'skips',                  skip_count,     '==',    0 ],
    [ 'duration(test)[s]',      test_duration,  '<=',    7 ],
    [ 'coverage(src)[%]',       app_coverage,   '==',  100 ],
    [ 'coverage(test)[%]',      test_coverage,  '==',  100 ],
    [ 'lines(test)/lines(src)', f2(line_ratio), '>=',  2.0 ],
    [ 'hits(src)/hits(test)',   f2(hits_ratio), '>=',  0.5 ],
  ]
end
