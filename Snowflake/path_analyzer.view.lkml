include: "exploded_paths.view.lkml"
include: "path_counts.view.lkml"
view: path_analyzer {
  derived_table: {
    sql: WITH

              -- To avoid having to deal with commas in future conditional CTAS
              syntax_ctas AS (SELECT TRUE)

              {% if path_analyzer.first_event_selector._in_query %}
              -- Find paths that contain the first event, and locate the first occurrence of that event
                , first_event_selector AS (
                  SELECT
                      path
                    , MIN(event_rank) AS first_occurrence
                  FROM ${exploded_paths.SQL_TABLE_NAME}
                  WHERE event_table_name = {% parameter first_event_selector %}
                  GROUP BY
                    path
                )
              {% endif %}

              {% if path_analyzer.last_event_selector._in_query %}
              -- Find paths that contain the last event, and locate the first occurrence of that event
              , last_event_selector AS (
                  SELECT
                      ep.path
                    , MIN(ep.event_rank) AS first_occurrence
                  FROM ${exploded_paths.SQL_TABLE_NAME} ep
                  {% if path_analyzer.first_event_selector._in_query %}
                    INNER JOIN first_event_selector fes
                    ON ep.path = fes.path AND ep.event_rank > fes.first_occurrence
                  {% endif %}
                  WHERE event_table_name = {% parameter last_event_selector %}
                  GROUP BY
                    ep.path
              )
              {% endif %}

              -- Find all paths with the first and last event (and their counts) and create a new path
              -- made up of only the events between the first and last event selected by the user.
              , sub_paths AS (
                  SELECT
                      pc.count
                    , pc.path as orig_path
                    , LISTAGG(ep.event_table_name, '- ')
                      WITHIN GROUP (ORDER BY ep.event_rank) AS path
                  FROM ${exploded_paths.SQL_TABLE_NAME} ep
                  INNER JOIN ${path_counts.SQL_TABLE_NAME} pc
                    ON ep.path = pc.path
                  {% if path_analyzer.first_event_selector._in_query %}
                    INNER JOIN first_event_selector fes
                      ON ep.path = fes.path AND ep.event_rank >= fes.first_occurrence
                  {% endif %}
                  {% if path_analyzer.last_event_selector._in_query %}
                    INNER JOIN last_event_selector les
                      ON ep.path = les.path AND ep.event_rank <= les.first_occurrence
                  {% endif %}
                  GROUP BY
                      pc.count
                    , pc.path
                )

            -- Sum everything up to find counts within the sub-path
              , sub_path_summary as (
                  SELECT
                      path
                    , SUM(count) as count
                  FROM sub_paths
                  GROUP BY
                      path
                )

              SELECT
                *
              -- If there aren't fitlers selected, go straight to the pre-built table
              FROM {% if path_analyzer.last_event_selector._in_query or path_analyzer.first_event_selector._in_query %}
                      sub_path_summary
                   {% else %}
                      ${path_counts.SQL_TABLE_NAME}
                   {% endif %}
        ;;

    }

    filter: first_event_selector {
      description: "The name of the event starting the path you would like to analyze."
      view_label: "Control Panel"
      type: string
      suggest_explore: event_counts
      suggest_dimension: event_counts.event_table_name
    }

    filter: last_event_selector {
      description: "The name of the event ending the path you would like to analyze."
      view_label: "Control Panel"
      type: string
      suggest_explore: event_counts
      suggest_dimension: event_counts.event_table_name
    }

    dimension: path {
      primary_key: yes
      type: string
      sql: ${TABLE}.path ;;
    }

    dimension: step_1 {
      type: string
      sql: SPLIT_PART(${TABLE}.path, '- ', 1) ;;
    }

    dimension: step_2 {
      type: string
      sql: SPLIT_PART(${TABLE}.path, '- ', 2) ;;
    }

    dimension: step_3 {
      type: string
      sql: SPLIT_PART(${TABLE}.path, '- ', 3) ;;
    }

    dimension: step_4 {
      type: string
      sql: SPLIT_PART(${TABLE}.path, '- ', 4) ;;
    }

    dimension: step_5 {
      type: string
      sql: SPLIT_PART(${TABLE}.path, '- ', 5) ;;
    }

    dimension: step_6 {
      type: string
      sql: SPLIT_PART(${TABLE}.path, '- ', 6) ;;
    }

    dimension: step_7 {
      type: string
      sql: SPLIT_PART(${TABLE}.path, '- ', 7) ;;
    }

    measure: total_sessions {
      description: "Total sessions with this path"
      type: sum
      sql: ${TABLE}.count ;;
    }

  }
