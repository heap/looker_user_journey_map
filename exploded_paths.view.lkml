include: "all_unique_events.view.lkml"
include: "session_paths.view.lkml"
view: exploded_paths {
  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM main_production.all_events;;
    distribution_style: all
    sql:  WITH

        example_paths as (
          SELECT
              user_id
            , session_id
            , path
            , ROW_NUMBER() OVER(
                PARTITION BY PATH
            ) AS example_rank
          FROM ${session_paths.SQL_TABLE_NAME} sp
        )

        SELECT
            ep.path
          , aue.event_table_name
          , aue.event_rank
        FROM ${all_unique_events.SQL_TABLE_NAME} aue
        INNER JOIN example_paths ep
          ON aue.user_id = ep.user_id
            AND aue.session_id = ep.session_id
              ;;
  }

  dimension: primary_key {
    hidden: yes
    sql:  ${TABLE}.path || ${TABLE}.event_rank ;;
  }

  dimension: path {
    sql: ${TABLE}.path ;;
  }

  dimension: event_table_name {
    sql: ${TABLE}.event_table_name ;;
  }

  dimension: event_rank {
    type: number
    sql: ${TABLE}.event_rank ;;
  }

}
