#	Title:       GUI timing histogram procedure
#
#	Description: This script generates GUI based timing histogram for all violating paths and captures it to a file.
#
#	Usage:       prompt> source ../scripts/histogram.tcl
#
#	Authors:     Sumeet Subhash Pawar



# starting the Design Vision GUI
start_gui

# obtaining timing paths (can provide delay_type, nworst, max_paths, slack_greater_than and slack_lesser_than)
change_selection [get_timing_paths -delay_type max -nworst 20 -max_paths 100 -slack_greater_than 0 -slack_lesser_than 1000]

# navigating to the menu bar and selecting "Slack Histogram of Selected Paths" from "Timing" option
gui_execute_menu_item -menu "Timing->Slack Histogram of Selected Paths"

# closing the Hier.1 window so as to only have the histogram on the screen
gui_close_window -window Hier.1

# navigating to the menu bar and selecting "Tile" from "Window" option so as to obtain a better view
gui_execute_menu_item -menu "Window->Tile"

# capturing the obtained histogram to a .jpg file which will be available in our work directory
gui_write_window_image -file path_slack_histogram.jpg


