def testflight_job_name(chart):
 return chart + "-testflight"
end

def bump_in_deployments_job_name(chart):
 return "bump-" + chart + "-in-deployments"
end

def chart_resource_name(chart):
  return chart + "-chart"
end

def group_job_names(charts, additional):
names = []
for chart_name in charts:
  names.append(testflight_job_name(chart_name))
  names.append(bump_in_deployments_job_name(chart_name))
end
names.extend(additional)
return names
end
