- dashboard: path_analysis
  title: Path Analysis
  layout: tile
  tile_size: 100

  filters:

  name: add_a_unique_name_1547511711
  title: Untitled Visualization
  model: journeys
  explore: path_analyzer
  type: sunburst
  fields: [path_analyzer.step_1, path_analyzer.step_2, path_analyzer.step_3, path_analyzer.step_4,
    path_analyzer.step_5, path_analyzer.total_sessions]
  sorts: [path_analyzer.total_sessions desc]
  limit: 500
  query_timezone: America/Los_Angeles
  series_types: {}
