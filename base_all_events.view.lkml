view: base_all_events {
  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM main_production.all_events;;
    distribution: "user_id"
    sortkeys: ["session_id", "time"]
    sql: (SELECT * FROM main_production.all_events
         WHERE time > CURRENT_DATE - INTERVAL '90 days')
      ;;
  }

}
