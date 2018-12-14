view: session_paths {
  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM main_production.all_events;;
    distribution: "user_id"
    sortkeys: ["session_id"]
    sql:
      SELECT
          user_id
        , session_id
        , LISTAGG(event_table_name, '| ')
            WITHIN GROUP (ORDER BY event_rank) AS path
      FROM ${all_unique_events.SQL_TABLE_NAME}
      GROUP BY
          user_id
        , session_id
      ;;
  }

  dimension: primary_key {
    hidden: yes
    sql: ${TABLE}.user_id || ${TABLE}.session_id;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}.session_id ;;
  }

  dimension: path {
    sql: ${TABLE}.path ;;
  }


}
