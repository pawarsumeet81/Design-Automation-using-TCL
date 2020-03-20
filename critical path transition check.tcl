#Title:       murali_task_2.tcl
#
#	Description: This Tcl procedure generates the transition values for the critical path and will indicate the pins over a designated threshold
# 	INPUTS:
#	 			N 	 - 	Max. Number of paths to be considered for get_timing_path
#	 			SLT  -	Slack Lesser Than value to be given to get_timing_path command
#		 		R_TRSH -  Rise transition threshold value
#				F_TRSH -  Fall transition threshold value
#	OUTPUTS:
#               List of pins  - With rise/fall transition over the given thresholds
#	   
#   Options:   	-N -SLT -R_TRSH -F_TRSH   Max. Number of paths with SLT value and threshold value
#
#	Usage:       prompt> source ../scripts/murali_task_2.tcl
#					   > murali_task_2 -help
#					   > murali_task_2 -N 5000 -SLT 0 -R_TRSH 0.01 -F_TRSH 0.06
#
#	Authors:     Murali Gullapalli

echo "\n\n\n\n Sourcing successful \n\n\n\n"
echo "Procedures in this file : my_task_2"
echo "use murali_task_2 -help for more info"


proc murali_task_2 args {
   # Parse the user inputs

   set option_N [lindex $args 0] 
   set value_N [lindex $args 1] 
   set option_SLT [lindex $args 2] 
   set value_SLT [lindex $args 3]
   set option_R_TRSH [lindex $args 4] 
   set value_R_TRSH [lindex $args 5]
   set option_F_TRSH [lindex $args 6] 
   set value_F_TRSH [lindex $args 7]


  #--------------------------------------------------
  #if my_task_2 -help is entered in DC shell
   if {[string match -help* $option_N]} {
       echo "\n\n\n\n  murali_task_2 : This Tcl procedure generates the transition values for the critical path and will indicate the pins over a designated threshold"
	   echo " "
	   echo "  Usage :   murali_task_2 -N <N value> -SLT <SLT value> -R_TRSH <R_TRSH value> -F_TRSH <F_TRSH value>"
	   echo " "
       echo "  -N     : Max. Number of paths to be considered for get_timing_path (0-10000)"
       echo "  -SLT   : Slack Lesser Than value to be given to get_timing_path command (0)"
	   echo "  -R_TRSH  : Rise transition threshold value (0.01-0.5)"
	   echo "  -F_TRSH  : Fall transition threshold value (0.01-0.5)\n\n\n\n"
       return
   	} elseif {[string match -N* $option_N] && [string match -SLT* $option_SLT] && [string match -R_TRSH* $option_R_TRSH] && [string match -F_TRSH* $option_F_TRSH]} {
		#if my_task_2 -N <N value> -SLT <SLT value> -R_TRSH <R_TRSH value> -F_TRSH <F_TRSH value> is entered in DC shell

		#Setting Internal variables	   
		set N $value_N
		set SLT $value_SLT
		set R_TRSH $value_R_TRSH 
		set F_TRSH $value_F_TRSH 
			
		#Printing the internal variables to check if the values are captured properly from the DC shell command line
		echo "********************************************************************"
		echo " "
		echo " "
		echo [format " Given N       : %10s " $N]
		echo [format " Given SLT     : %10s " $SLT]
		echo [format " Given R_TRSH  : %10s " $R_TRSH]
		echo [format " Given F_TRSH  : %10s " $F_TRSH]
		echo " "
		echo " "
		echo "********************************************************************"
		echo " "
		echo " "
		echo "************************** REPORTING TIMING**************************"
		report_timing 
		echo "***************************REPORT_TIMING COMPLETE*********************************"
		
		
		#Getting all the required paths based on the given N and SLT values and choosing one path at a time from the resulting collection to be processed
		for {set i 0} {$i < $N} {incr i} {			
			set path [index_collection [get_timing_paths -max_paths $N -slack_lesser_than $SLT] $i]
			
			set path_full_name [get_attribute $path full_name]

			echo [format "PATH : %d (Full name : %s)\n\n" $i $path_full_name]

			#Obtaining Start points, end points and slack values for the current path
			set  start_point [get_attribute $path startpoint]
			set  start_point_ref_name [get_attribute $start_point full_name]

			set  end_point [get_attribute $path endpoint]
			set  end_point_ref_name [get_attribute $end_point full_name]

			set  path_slack [get_attribute $path slack]


			echo [format "Path %d Start Point : %s  \nPath %d End Point   : %s \nPath %d Slack       : %s\n" $i $start_point_ref_name $i $end_point_ref_name $i $path_slack]
			
		
			set all_points_per_path [get_attribute $path points]
			set my_size [sizeof_collection $all_points_per_path]
			echo [format "Total number of points in path %d : %1s" $i $my_size ]

			set all_pins_per_path [get_attribute $all_points_per_path object]
			set my_size [sizeof_collection $all_pins_per_path]
			echo [format "Total number of pins in path   %d : %1s\n\n" $i $my_size ]

			echo [format "Pins in path %d with Rise Transition > %s and Fall Transition > %s are :\n" $i $R_TRSH $F_TRSH]

			foreach_in_collection pin_x $all_pins_per_path {

				set my_index [lindex $pin_x]
				set  pin_ref_name [get_attribute $pin_x full_name]

				#Using actual_rise_transition_max and actual_fall_transition attributes to obtain Rise and Fall transition values for the current Pin 
				set rise_trans [get_attribute $pin_x -quiet actual_rise_transition_max]

				set fall_trans [get_attribute $pin_x -quiet actual_fall_transition_max]

				#comparing the obtained Rise and Fall transition values with the given input Threshold values
				if {($rise_trans > $R_TRSH) || ($fall_trans > $F_TRSH)} {

					#Printing in the required format
					puts [format "Pin : %25s     Rise Transition : %5s    Fall Transition : %5s" $pin_ref_name $rise_trans $fall_trans] 
				}
							
			}
			echo "\n--------------------------------------------------------------------------------------------\n"
		}
	}
}
