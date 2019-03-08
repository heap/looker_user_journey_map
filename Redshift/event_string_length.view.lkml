include: "all_unique_events.view.lkml"
view: event_string_length {
  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM main_production.all_events;;
    distribution: "user_id"
    sortkeys: ["session_id"]
    sql:
        SELECT
            user_id as user_id
          , session_id as session_id
          , event_rank as event_rank
          -- +3 for the ' - ' list-agg separator characters
          , SUM(LEN(event_table_name) + 3) OVER (
              PARTITION BY  user_id, session_id
              ORDER BY event_rank
              ROWS BETWEEN UNBOUNDED PRECEDING
              AND CURRENT ROW
            ) AS cumulative_characters
        FROM ${all_unique_events.SQL_TABLE_NAME}
      ;;
  }

}
