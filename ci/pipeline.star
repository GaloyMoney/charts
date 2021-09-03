def testflight_job_name(chart):
 return chart + "-testflight"
end

def bump_in_deployments_job_name(chart):
 return "bump-" + chart + "-in-deployments"
end

def chart_resource_name(chart):
  return chart + "-chart"
end
