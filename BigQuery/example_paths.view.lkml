view: example_paths {
  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM main_production.all_events;;
    distribution_style: all
    sql: WITH

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

        SELECT *
        FROM example_paths
        WHERE example_rank = 1
      ;;
  }

}
