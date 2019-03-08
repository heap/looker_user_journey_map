include: "event_string_length.view.lkml"
view: session_paths {
  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM main_production.all_events;;
    distribution: "user_id"
    sortkeys: ["session_id"]
    sql:
      SELECT
          aue.user_id
        , aue.session_id
        , LISTAGG(aue.event_table_name, ' - ')
            WITHIN GROUP (ORDER BY aue.event_rank) AS path
      FROM ${all_unique_events.SQL_TABLE_NAME} aue
      INNER JOIN ${event_string_length.SQL_TABLE_NAME} esl
        ON aue.user_id = esl.user_id
        AND aue.session_id = esl.session_id
        AND aue.event_rank = esl.event_rank
        -- Prevent list-agg character limit overflow errors
        AND esl.cumulative_characters < 65535
      GROUP BY
          aue.user_id
        , aue.session_id
      ;;
  }

  dimension: primary_key {
    hidden: yes
    sql: ${TABLE}.user_id || ${TABLE}.session_id;;
  }

  dimension: path {
    sql: ${TABLE}.path ;;
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}.session_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

}
