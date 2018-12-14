view: event_counts {
  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM main_production.all_events;;
    distribution_style: all
    sql: SELECT
          event_table_name
        , count(*)
      FROM main_production.all_events
      GROUP BY
          event_table_name
       ;;
  }

  dimension: event_table_name {
    primary_key: yes
    type: string
    sql: ${TABLE}.event_table_name ;;
  }

  dimension: count {
    type: number
    sql: ${TABLE}.count ;;
  }

}
