include: "session_paths.view.lkml"
view: path_counts {
  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM main_production.all_events;;
    distribution_style: all
    sql:
        SELECT
            path
          , count(*)
        FROM ${session_paths.SQL_TABLE_NAME}
        GROUP BY path
      ;;
  }

  dimension: count {
    description: "Number of sessions with this path"
    type: number
    sql: ${TABLE}.count ;;
  }

  dimension: path {
    primary_key: yes
    type: string
    sql: ${TABLE}.path ;;
  }

}
