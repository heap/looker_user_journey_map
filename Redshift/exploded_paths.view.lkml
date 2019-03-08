include: "all_unique_events.view.lkml"
include: "example_paths.view.lkml"

view: exploded_paths {
  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM main_production.all_events;;
    distribution: "path"
    sortkeys: ["event_table_name"]
    sql:
        SELECT
            ep.path
          , aue.event_table_name
          , aue.event_rank
          , esl.cumulative_characters
        FROM ${all_unique_events.SQL_TABLE_NAME} aue
        INNER JOIN ${example_paths.SQL_TABLE_NAME} ep
          ON aue.user_id = ep.user_id
            AND aue.session_id = ep.session_id
        INNER JOIN ${event_string_length.SQL_TABLE_NAME} esl
          ON aue.user_id = esl.user_id
          AND aue.session_id = esl.session_id
          AND aue.event_rank = esl.event_rank
          -- Prevent list-agg character limit overflow errors
          AND esl.cumulative_characters < 65535
          ;;
  }

  dimension: event_rank {
    type: number
    sql: ${TABLE}.event_rank ;;
  }

  dimension: event_table_name {
    sql: ${TABLE}.event_table_name ;;
  }

  dimension: path {
    sql: ${TABLE}.path ;;
  }

  dimension: primary_key {
    hidden: yes
    sql:  ${TABLE}.path || ${TABLE}.event_rank ;;
  }


}
