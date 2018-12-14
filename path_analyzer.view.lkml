include: "exploded_paths.view.lkml"
include: "path_counts.view.lkml"
view: path_analyzer {
  derived_table: {
    sql: WITH

        -- Find paths that contain the first event, and locate the first occurrence of that event
        first_event_selector AS (
          SELECT
              path
            , MIN(event_rank) AS first_occurrence
          FROM ${exploded_paths.SQL_TABLE_NAME}
          WHERE event_name = {% parameter first_event_selector %}
          GROUP BY
            path
        )

        -- Find paths that contain the last event, and locate the first occurrence of that event
        , last_event_selector AS (
          SELECT
              ep.path
            , MIN(ep.event_rank) AS first_occurrence
          FROM ${exploded_paths.SQL_TABLE_NAME} ep
          INNER JOIN first_event_selector fes
          ON ep.path = fes.path
            AND ep.event_rank > fes.first_occurrence
          WHERE event_name = {% parameter last_event_selector %}
          GROUP BY
            ep.path
        )

        -- Find all paths with the first and last event (and their counts) and create a new path
        -- made up of only the events between the first and last event selected by the user.
        sub_paths AS (
          SELECT
              pc.count
            , LISTAGG(ep.event_table_name, '| ')
              WITHIN GROUP (ORDER BY ep.event_rank) AS path
          FROM ${exploded_paths.SQL_TABLE_NAME} ep
          INNER JOIN first_event_selector fes
            ON ep.path = fes.path
              AND ep.event_rank >= fes.event_rank
          INNER JOIN last_event_selector les
            ON ep.path = les.path
              AND ep.event_rank <= les.event_rank
          INNER JOIN ${path_counts.SQL_TABLE_NAME} pc
            ON ep.path = pc.path
          GROUP BY pc.count
      )

      -- Sum everything up to find counts within the sub-path
      SELECT
          path
        , SUM(count) as count
      FROM sub_paths
      GROUP BY
          path
      ;;
  }

  dimension: path {
    primary_key: yes
    type: string
    sql: ${TABLE}.event_table_name ;;
  }

  measure: total_sessions {
    description: "Total sessions with this path"
    type: sum
    sql: ${TABLE}.count ;;
  }

  filter: first_event_selector {
    description: "The name of the event starting the path you would like to analyze."
    view_label: "Control Panel"
    type: string
    suggest_dimension: event_counts.event_table_name
  }

  filter: last_event_selector {
    description: "The name of the event ending the path you would like to analyze."
    view_label: "Control Panel"
    type: string
    suggest_dimension: event_counts.event_table_name
  }

}
