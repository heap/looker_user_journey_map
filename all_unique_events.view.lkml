include: "base_all_events.view.lkml"
include: "event_counts.view.lkml"
view: all_unique_events {
  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM main_production.all_events;;
    distribution: "user_id"
    sortkeys: ["session_id", "time"]
    sql: WITH

        event_selector AS (
          SELECT
              ae.*
            , ROW_NUMBER() OVER (
              PARTITION BY ae.user_id, ae.event_id
              ORDER BY ec.count ASC
            ) AS name_rank
          FROM ${base_all_events.SQL_TABLE_NAME} ae
          LEFT JOIN ${event_counts.SQL_TABLE_NAME} ec
            ON ae.event_table_name = ec.event_table_name
        )

        SELECT
            user_id
          , "time"
          , event_id
          , session_id
          , TRIM(event_table_name) AS event_table_name
          , ROW_NUMBER() OVER (
            PARTITION BY user_id, session_id
            ORDER BY "time" ASC
          ) AS event_rank
        FROM event_selector
        WHERE name_rank = 1
      ;;
  }

  dimension: event_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.event_id ;;
  }

  dimension: event_rank {
    type: number
    sql: ${TABLE}.event_rank ;;
  }

  dimension: event_table_name {
    type: string
    sql: ${TABLE}.event_table_name ;;
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}.session_id ;;
  }

  dimension: time {
    type: date_time
    sql: ${TABLE}.time ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

}
