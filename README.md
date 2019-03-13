# README

Welcome to the User Journey Analysis Block. This block will give you insight into user flows throughout your product. Follow the instructions below in order to configure the block to your Looker instance.


# User Journey Analysis:

1. Turn on Custom Visualizations in your lab settings: https://docs.looker.com/admin-options/platform/visualizations
2. Make sure Persistent Derived Tables under connections are turned on
3. Make a new visualization in Admin --> Platform --> Visualization
- How to add a custom visulization: https://docs.looker.com/admin-options/platform/visualizations#adding_a_new_custom_visualization_manifest
- Use this link for the visuzalization: https://4mile.github.io/sunburst.js
4. Update the model file to reflect your warehouse connection name (Note: if you aren't querying from the main_production schema, you will have to update to the correct schema name in the LookML files)
5. Select the LookML files for your specific warehouse (Redshift, Snowflake, or BigQuery)
6. Copy and Paste these files into a new or existing LookML project for your Heap database connection
