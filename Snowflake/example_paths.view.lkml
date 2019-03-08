view: example_paths {
  derived_table: {
    sql_trigger_value: SELECT COUNT(*) FROM main_production.all_events;;
    sql: WITH

              example_paths_cte as (
                SELECT
                    user_id
                  , session_id
                  , path
                  , ROW_NUMBER() OVER(
                      PARTITION BY PATH
                      ORDER BY session_id
                  ) AS example_rank
                FROM ${session_paths.SQL_TABLE_NAME} sp
              )

              SELECT *
              FROM example_paths_cte
              WHERE example_rank = 1
            ;;
  }

}
