view: path_counts {
  derived_table: {
    sql:
        SELECT
            path
          , count(*)
        FROM ${session_paths.SQL_TABLE_NAME}
        GROUP BY path
      ;;
  }

  dimension: path {
    primary_key: yes
    type: string
    sql: ${TABLE}.path ;;
  }

  dimension: count {
    description: "Number of sessions with this path"
    type: number
    sql: ${TABLE}.count ;;
  }


}
