#Title:       murali_task_1.tcl
#
#	Description: This Tcl procedure generates specific outputs given user input.
# 	INPUTS:
#	 			N 	 - 	Max. Number of paths to be considered for get_timing_path
#	 			SLT  -	Slack Lesser Than value to be given to get_timing_path command
#		 		TRSH -  Max. number of logic levels to look for in each path
#	OUTPUTS:
#               Total_cells  - Total number of cells in each path (Total number of logic levels)
#               Path with the max. no. of non-inverter/buffer/flipflop logic levels
#	   
#   Options:   	-N -SLT   		Max. Number of paths with SLT value
#				-N -SLT -TRSH   Max. Number of paths with SLT value and threshold value
#
#	Usage:       prompt> source ../scripts/murali_task_1.tcl
#					   > murali_task_1 -help
#					   > murali_task_1 -N 5000 -SLT 0 -TRSH 100
#
#	Authors:     Murali Gullapalli


echo "\n\n\n\n Sourcing successful \n\n\n\n"
echo "Procedures in this file : my_task_1"
echo "use murali_task_1 -help for more info"


proc murali_task_1 args {
   # Parse the user inputs

   set option_N [lindex $args 0] 
   set value_N [lindex $args 1] 
   set option_SLT [lindex $args 2] 
   set value_SLT [lindex $args 3]
   set option_TRSH [lindex $args 4] 
   set value_TRSH [lindex $args 5]

   if {[string match -help* $option_N]} {
       echo " \n\n\n\n  murali_task_1 : This tcl script finds the path with largest number of logic levels Without BUF/INV levels "
	   echo " "
	   echo "  Usage :   murali_task_1 -N <N value> -SLT <SLT value> -TRSH <TRSH value>"
	   echo " "
       echo "  -N     : Max. Number of paths to be considered for get_timing_path (0-10000)"
       echo "  -SLT   : Slack Lesser Than value to be given to get_timing_path command (0)"
	   echo "  -TRSH  : Max. number of logic levels to look for in each path (100)\n\n\n\n"
       return
   	} elseif {[string match -N* $option_N] && [string match -SLT* $option_SLT] && ([string match -TRSH* $option_TRSH]==0)} { 
		# If Threshold is not mentioned [my_proc -N 10000 -SLT 0]
		echo "Threshold not mentioned - inside 1st elseif block"
		set N $value_N
		set SLT $value_SLT 

		echo "********************************************************************"
		echo " "
		echo " "
		echo [format " Given N    : %2s " $N]
		echo [format " Given SLT  : %2s " $SLT]
		echo " "
		echo " "
		echo "********************************************************************"
		echo " "
		echo " "
		echo " "
		echo " "
		echo " "
		echo "************************** REPORTING TIMING**************************"
		report_timing 
		echo "***************************REPORT_TIMING COMPLETE*********************************"
		echo " "
		echo " "
		echo " "
		echo " "
		echo " "
		#--------------------------------INTERNAL COUNTER VARIABLES AND ARRAYS-------------------------------------
		array set cell_count_per_path {}
		array set curr_count {}
		set curr_count(0) 0
		set req_index 0
		array set temp_path_cells {}
		#----------------------------------------------------------------------------------------------------------
		

		# To find the Total Number of cells in the each Timing Path

		for {set i 0} {$i < $N} {incr i} {		

			set temp_path_cell_counter 0	

			set path [index_collection [get_timing_paths -max_paths $N -slack_lesser_than $SLT] $i]

			set path_full_name [get_attribute $path full_name]

			echo [format "PATH : %d (Full name : %s)\n\n" $i $path_full_name]


			#set  start_points [get_attribute $path startpoint]
			#set  end_points [get_attribute $path endpoint]
		
			set all_points_per_path [get_attribute $path points]

			#set my_size [sizeof_collection $all_points_per_path]
			#echo [format "Total number of all_points_per_path : %1s" $my_size ]
	
			set all_objs_per_path [get_attribute $all_points_per_path object]

			#set my_size [sizeof_collection $all_objs_per_path]
			#echo [format "Total number of all_objs_per_path : %1s" $my_size ]

			set itr_x 0
			foreach_in_collection itr $all_objs_per_path {
				
				set cell_x [get_cell -of_obj $itr]
				set ref_name_x [get_attribute $cell_x ref_name]
				set full_name_x [get_attribute $cell_x full_name]

				if {([string match INV* $ref_name_x]==0) && ([string match *BUFF* $ref_name_x]==0) && ([string match SDFF* $ref_name_x]==0)} { incr temp_path_cell_counter }
				
				echo [format "cell : %2d     Full name : %23s     ref name : %12s    req_cell_count : %d" $itr_x $full_name_x $ref_name_x $temp_path_cell_counter]
				
				incr itr_x			
			}
				
			set cell_count_per_path($i) $temp_path_cell_counter

			echo [format "\n\nnumber of non inv / buf / FF cells in path %d is : %d \n\n " $i $cell_count_per_path($i)]
			echo "------------------------------------------------------------------------------------------"
		}
				
		set len_of_arr [array size cell_count_per_path]
				
		for {set i 0} {$i < $len_of_arr} {incr i} {
				
			if {$cell_count_per_path($i) > $curr_count(0)} { 
				set req_index $i
				set curr_count(0) $cell_count_per_path($i)
			}
				
		}

		#set final_path [index_collection [get_timing_paths -max_paths $N -slack_lesser_than $SLT] $req_index]
		echo "======TASK 1 OUTPUTP : PATH WITH HIGHEST NUMBER OF NON INV/BUF/FF LEVELS is======"
		echo "Path :\t"		
		return lindex $path $req_index
	} elseif {[string match -N* $option_N] && [string match -SLT* $option_SLT] && [string match -TRSH* $option_TRSH]} {
		echo "Threshold is mentioned - inside 2nd elseif block"
			   
		set N $value_N
		set SLT $value_SLT
		set TRSH $value_TRSH 
			

		echo "********************************************************************"
		echo " "
		echo " "
		echo [format " Given N     : %2s " $N]
		echo [format " Given SLT   : %2s " $SLT]
		echo [format " Given TRSH  : %2s " $TRSH]
		echo " "
		echo " "
		echo "********************************************************************"
		echo " "
		echo " "
		echo " "
		echo " "
		echo " "
		echo "************************** REPORTING TIMING**************************"
		report_timing 
		echo "***************************REPORT_TIMING COMPLETE*********************************"
		echo " "
		echo " "
		echo " "
		echo " "
		echo " "
		#--------------------------------INTERNAL COUNTER VARIABLES AND ARRAYS-------------------------------------
		array set cell_count_per_path {}
		array set paths_exceeding_threshold {}
		set req_index 0
		#----------------------------------------------------------------------------------------------------------
		
		# To find the Total Number of cells in the each Timing Path
		for {set i 0} {$i < $N} {incr i} {			
			
			set temp_path_cell_counter 0	
			
			set path [index_collection [get_timing_paths -max_paths $N -slack_lesser_than $SLT] $i]

			set path_full_name [get_attribute $path full_name]

			echo [format "PATH : %d (Full name : %s)\n\n" $i $path_full_name]

			#set  start_points [get_attribute $path startpoint]
			#set  end_points [get_attribute $path endpoint]
		
			set all_points_per_path [get_attribute $path points]
			#echo "-------------- all points per path are captured ------------------"

			#set my_size [sizeof_collection $all_points_per_path]
			#echo [format "Total number of all_points_per_path : %1s" $my_size ]
	
			set all_objs_per_path [get_attribute $all_points_per_path object]

			#set my_size [sizeof_collection $all_objs_per_path]
			#echo [format "Total number of all_objs_per_path : %1s" $my_size ]


			set itr_x 0
			foreach_in_collection itr $all_objs_per_path {
				set cell_x [get_cell -of_obj $itr]
				set ref_name_x [get_attribute $cell_x ref_name]
				set full_name_x [get_attribute $cell_x full_name]

				if {([string match INV* $ref_name_x]==0) && ([string match *BUFF* $ref_name_x]==0) && ([string match SDFF* $ref_name_x]==0)} { incr temp_path_cell_counter }
				
				echo [format "cell : %2d     Full name : %23s     ref name : %12s    req_cell_count : %d" $itr_x $full_name_x $ref_name_x $temp_path_cell_counter]
				
				incr itr_x			
			}
				
			set cell_count_per_path($i) $temp_path_cell_counter

			echo [format "\n\nnumber of non inv / buf / FF cells in path %d is : %d \n\n " $i $cell_count_per_path($i)]
			echo "------------------------------------------------------------------------------------------"
		}
				
		set len_of_arr_1 [array size cell_count_per_path]
		set j 0
		for {set k 0} {$k < $len_of_arr_1} {incr k} {
			
			if {$cell_count_per_path($k) > $TRSH } { 
				#set req_index $i
				set paths_exceeding_threshold($j) $k
				incr j
				
			}	
		}

		echo [format "Paths which are exceeding the given cell count threshhold of %d are " $TRSH]
		set len_of_arr_2 [array size paths_exceeding_threshold]
		for {set l 0} {$l < $len_of_arr_2} {incr l} {
			
			echo [format "Path : %d" $paths_exceeding_threshold($l)]		
				
		}	

	}
	
}

