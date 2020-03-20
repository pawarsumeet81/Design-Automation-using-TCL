#   Title:       my_proc.tcl
#
#	Description: This Tcl procedure generates specific outputs given user input.
# 	INPUTS:
#	 			N 	 - 	Max. Number of paths to be considered for get_timing_path
#		 		TRSH -  Max. number of logic levels to look for in each path
#	OUTPUTS:
#               * histogram of levels of logic in violating paths
#	   
#   Options:   	-N  		Max. Number of paths
#				-N -TRSH   Max. Number of paths with threshold value
#
#	Usage:       prompt> source ../scripts/my_proc.tcl
#					   > my_proc -help
#					   > my_proc -N 20 -TRSH 3
#
#	Author:     Pooja Gopalakrishnan
proc my_proc args {
   #suppress_message UID-101
   ################################################
   # Parse the user inputs

   set option_N [lindex $args 0] 
   set value_N [lindex $args 1] 
   set option_TRSH [lindex $args 2] 
   set value_TRSH [lindex $args 3]


  #--------------------------------------------------
   if {[string match -help* $option_N]} {
       echo " my_proc : This tcl script prints the logic levels Without BUF/INV levels in violating paths "
	   echo " "
	   echo " Usage   : my_proc -N <N value> -TRSH <TRSH value>"
	   echo " "
       echo " -N      : Max. Number of paths to be considered for get_timing_path "
	   echo " -TRSH   : Threshold for number of logic levels to look for in each path "
       return
   	} elseif {[string match -N* $option_N] && ([string match -TRSH* $option_TRSH]==0)} { 
		# If Threshold is not mentioned [my_proc -N 10000 -SLT 0]
		echo " "
		echo " "
		echo [format " Threshold not mentioned - inside 1st elseif block"]
		echo " "
		echo " "
		set N $value_N 
		echo "********************************************************************"
		echo " "
		echo [format " Given N : %2d " $N]
		echo " "
		echo "********************************************************************"
		#echo "************************** REPORTING TIMING**************************"
		#report_timing -slack_lesser_than 0
		#echo "***************************REPORT_TIMING COMPLETE*********************************"

		#--------------------------------INTERNAL COUNTER VARIABLES AND ARRAYS-------------------------------------
		array set cell_count_per_path {}
		array set curr_count_max {}
		set curr_count_max(0) 0
		array set curr_count_min {}
		set curr_count_min(0) 0
		set req_index1 0
		set req_index2 0
		set count1 0
        set count2 0
        set count3 0
        set count4 0
        set count5 0
		#----------------------------------------------------------------------------------------------------------
		
		# To find the Total Number of cells in the each Timing Path

		for {set i 0} {$i < $N} {incr i} {
		
			set path [index_collection [get_timing_paths -max_paths $N -slack_lesser_than 0] $i]

			#echo "*******************inside for loop*********************\n\n"
			#echo "value of i is "
			#echo $i
		    #echo "-------------- all paths are captured ------------------"
			set  start_points [get_attribute $path startpoint]
			set  end_points [get_attribute $path endpoint]
			#echo "-------------- start,end points are captured ------------------"
	
			set all_points_per_path [get_attribute $path points]
			#echo "-------------- all points per path are captured ------------------"
			set all_objs_per_path [get_attribute $all_points_per_path object]
			#echo "-------------- all objects per path are captured ------------------"
			set all_cells_per_path [get_cell -of_obj $all_objs_per_path]
			#echo "-------------- all cells per path are captured ------------------"
			
			#echo "----------------------- INITIAL REF_NAMES -----------------"
			set init_ref_names [get_attribute $all_cells_per_path ref_name]
			#echo $init_ref_names
			#echo "-------------- all intital ref names per path are captured ------------------"
			set filtered_coll_of_cells [get_cell -of_obj $all_objs_per_path -filter "ref_name!~*INV* && ref_name!~*BUF* && ref_name!~*SDFF*"]
			
			#echo "----------------------- FINAL REF_NAMES -----------------"
			set final_ref_names [get_attribute $filtered_coll_of_cells ref_name]
			#echo $final_ref_names
			
			set cell_count_per_path($i) [llength $final_ref_names]

			#echo [format "number of non inv / buf cells in path is : %d" $cell_count_per_path($i) ]

		}
				
		set len_of_arr [array size cell_count_per_path]
		#echo "length of array $len_of_arr"	
		for {set i 0} {$i < $len_of_arr} {incr i} {
			
			if {$cell_count_per_path($i) > $curr_count_max(0) } { 
			set req_index1 $i
			set curr_count_max(0) $cell_count_per_path($i)
			}
		}
		echo " "
		echo [format " Maximum levels of logic is : %d" $curr_count_max(0) ]
		
		set curr_count_min(0) $curr_count_max(0)
		
		for {set i 0} { $i < $len_of_arr} {incr i} {
			
			if {$cell_count_per_path($i) < $curr_count_min(0)} { 
			set req_index2 $i
			set curr_count_min(0) $cell_count_per_path($i)
			}	
		}

		echo [format " Minimum levels of logic is : %d" $curr_count_min(0) ]
			
		set my_range [expr {($curr_count_max(0)) - ($curr_count_min(0))}]
        #puts " Range     : $my_range"
        set interval [expr {$my_range/5}]
		set remainder [expr {fmod($my_range,5)}]
		#echo " Remainder : $remainder"
        #puts " Interval  : $interval"
		if {$interval != 0} {
        set max1 [expr {$curr_count_min(0) + $interval}]
        set max2 [expr {$max1 + $interval}]
        set max3 [expr {$max2 + $interval}]
        set max4 [expr {$max3 + $interval}]
        set max5 [expr {$max4 + $interval + $remainder}]
        set string1 "Logic levels $curr_count_min(0) to $max1 "
        set string2 "Logic levels $max1 to $max2 "
        set string3 "Logic levels $max2 to $max3 "
        set string4 "Logic levels $max3 to $max4 "
        set string5 "Logic levels $max4 to $max5 "
        #puts " Max1=$max1 Max2=$max2 Max3=$max3 Max4=$max4 Max5= $max5"

		for {set j 0} {$j < $len_of_arr} {incr j} {
		#puts " count is $cell_count_per_path($j)"
			if {($max1)>($cell_count_per_path($j)) && ($cell_count_per_path($j))>=($curr_count_min(0))} {
			incr count1
			} elseif {($max2)>($cell_count_per_path($j)) && ($cell_count_per_path($j))>=($max1)} {
				incr count2
				} elseif {($max3)>($cell_count_per_path($j)) && ($cell_count_per_path($j))>=($max2)} {
					incr count3
					} elseif {($max4)>($cell_count_per_path($j)) && ($cell_count_per_path($j))>=($max3)} {
						incr count4
						} elseif {($max5)>=($cell_count_per_path($j)) && ($cell_count_per_path($j))>=($max4)} {
							incr count5
						}
		}
				
		puts " $string1   ------> $count1 \n $string2   ------> $count2 \n $string3   ------> $count3 \n $string4   ------> $count4 \n $string5------> $count5 \n\n"
        echo " ********************************************************************** "
        echo "       Histogram of levels of logic in violating paths"
        echo " ********************************************************************** \n\n"
        echo " In the histogram, each * represents 1 logic level \n\n"
        puts -nonewline "$string1      "

        for {set i 0} {$i < [expr $count1/1]} {incr i} {
            puts -nonewline "*"
        }
        puts "\n"
        puts -nonewline "$string2      "
        for {set j 0} {$j < [expr $count2/1]} {incr j} {
        puts -nonewline "*"
        }
        puts "\n"
        puts -nonewline "$string3      "
        for {set k 0} {$k < [expr $count3/1]} {incr k} {
        puts -nonewline "*"
		}
        puts "\n"
        puts -nonewline "$string4      "
        for {set l 0} {$l < [expr $count4/1]} {incr l} {
        puts -nonewline "*"
        }
        puts "\n"
        puts -nonewline "$string5   "
        for {set m 0} {$m < [expr $count5/1]} {incr m} {
        puts -nonewline "*"
        }
        puts "\n"
        } else {
		set max1 [expr {$curr_count_min(0) + 1}]
        set max2 [expr {$max1 + 1}]
        set max3 [expr {$max2 + 1}]
        set max4 [expr {$max3 + 1}]
        set max5 [expr {$max4 + 1}]
        set string1 "Logic levels $curr_count_min(0) to $max1 "
        set string2 "Logic levels $max1 to $max2 "
        set string3 "Logic levels $max2 to $max3 "
        set string4 "Logic levels $max3 to $max4 "
        set string5 "Logic levels $max4 to $max5 "
        #puts " Max1=$max1 Max2=$max2 Max3=$max3 Max4=$max4 Max5= $max5"

		for {set j 0} {$j < $len_of_arr} {incr j} {
		#puts " count is $cell_count_per_path($j)"
			if {($max1)>($cell_count_per_path($j)) && ($cell_count_per_path($j))>=($curr_count_min(0))} {
			incr count1
			} elseif {($max2)>($cell_count_per_path($j)) && ($cell_count_per_path($j))>=($max1)} {
				incr count2
				} elseif {($max3)>($cell_count_per_path($j)) && ($cell_count_per_path($j))>=($max2)} {
					incr count3
					} elseif {($max4)>($cell_count_per_path($j)) && ($cell_count_per_path($j))>=($max3)} {
						incr count4
						} elseif {($max5)>=($cell_count_per_path($j)) && ($cell_count_per_path($j))>=($max4)} {
							incr count5
						}
		}
				
		echo [format " $string1  ------> %2d \n $string2  ------> %2d \n $string3  ------> %2d \n $string4  ------> %2d \n $string5  ------> %2d \n " $count1 $count2 $count3 $count4 $count5]
        echo " ********************************************************************** "
        echo "       Histogram of levels of logic in violating paths"
        echo " ********************************************************************** \n\n"
        echo " In the histogram, each * represents 1 logic level \n\n"
        puts -nonewline "$string1      "

        for {set i 0} {$i < [expr $count1/1]} {incr i} {
            puts -nonewline "*"
        }
        puts "\n"
        puts -nonewline "$string2      "
        for {set j 0} {$j < [expr $count2/1]} {incr j} {
        puts -nonewline "*"
        }
        puts "\n"
        puts -nonewline "$string3      "
        for {set k 0} {$k < [expr $count3/1]} {incr k} {
        puts -nonewline "*"
		}
        puts "\n"
        puts -nonewline "$string4      "
        for {set l 0} {$l < [expr $count4/1]} {incr l} {
        puts -nonewline "*"
        }
        puts "\n"
        puts -nonewline "$string5   "
        for {set m 0} {$m < [expr $count5/1]} {incr m} {
        puts -nonewline "*"
        }
        puts "\n"
		}

	} elseif {[string match -N* $option_N] && [string match -TRSH* $option_TRSH]} { 
		# If Threshold is mentioned [my_proc -N 100 -TRSH 2]
		echo " "
		echo " "
		echo [format "Threshold mentioned - inside 2nd elseif block"]
		echo " "
		echo " "
		set N $value_N
		set TRSH $value_TRSH
		echo "********************************************************************"
		echo " "
		echo [format " Given    N : %2d " $N]
		echo [format " Given TRSH : %2d " $TRSH]
		echo " "
		echo "********************************************************************"
		#echo "************************** REPORTING TIMING**************************"
		#report_timing -slack_lesser_than 0
		#echo "***************************REPORT_TIMING COMPLETE*********************************"

		#--------------------------------INTERNAL COUNTER VARIABLES AND ARRAYS-------------------------------------
		array set cell_count_per_path {}
		array set filtered_cell_count_per_path {}
		array set curr_count_max {}
		set curr_count_max(0) 0
		array set curr_count_min {}
		set curr_count_min(0) 0
		set req_index1 0
		set req_index2 0
		set count1 0
        set count2 0
        set count3 0
        set count4 0
        set count5 0
		#----------------------------------------------------------------------------------------------------------
		
		# To find the Total Number of cells in the each Timing Path

		for {set i 0} {$i < $N} {incr i} {
		
			set path [index_collection [get_timing_paths -max_paths $N -slack_lesser_than 0] $i]

			#echo "*******************inside for loop*********************\n\n"
			#echo "value of i is "
			#echo $i
		    #echo "-------------- all paths are captured ------------------"
			set  start_points [get_attribute $path startpoint]
			set  end_points [get_attribute $path endpoint]
			#echo "-------------- start,end points are captured ------------------"
	
			set all_points_per_path [get_attribute $path points]
			#echo "-------------- all points per path are captured ------------------"
			set all_objs_per_path [get_attribute $all_points_per_path object]
			#echo "-------------- all objects per path are captured ------------------"
			set all_cells_per_path [get_cell -of_obj $all_objs_per_path]
			#echo "-------------- all cells per path are captured ------------------"
			
			#echo "----------------------- INITIAL REF_NAMES -----------------"
			set init_ref_names [get_attribute $all_cells_per_path ref_name]
			#echo $init_ref_names
			#echo "-------------- all intital ref names per path are captured ------------------"
			set filtered_coll_of_cells [get_cell -of_obj $all_objs_per_path -filter "ref_name!~*INV* && ref_name!~*BUF* && ref_name!~*SDFF*"]
			
			#echo "----------------------- FINAL REF_NAMES -----------------"
			set final_ref_names [get_attribute $filtered_coll_of_cells ref_name]
			#echo $final_ref_names
			
			set cell_count_per_path($i) [llength $final_ref_names]

			#echo [format "number of non inv / buf cells in path is : %d" $cell_count_per_path($i) ]

		}
				
		set len_of_arr [array size cell_count_per_path]
		#echo "length of array $len_of_arr"	
		set j 0
		for {set i 0} {$i < $len_of_arr} {incr i} {
			if {$cell_count_per_path($i) > $TRSH } { 
			set filtered_cell_count_per_path($j) $cell_count_per_path($i)
			incr j
			}
		}
		set len_of_filtered_arr [array size filtered_cell_count_per_path]
		
		for {set i 0} {$i < $len_of_filtered_arr} {incr i} {
			
			if {$filtered_cell_count_per_path($i) > $curr_count_max(0) } { 
			set req_index1 $i
			set curr_count_max(0) $filtered_cell_count_per_path($i)
			}
		}
		echo " "
		echo [format " Maximum levels of logic is : %d" $curr_count_max(0) ]
		
		set curr_count_min(0) $curr_count_max(0)
		
		for {set i 0} { $i < $len_of_filtered_arr} {incr i} {
			
			if {$filtered_cell_count_per_path($i) < $curr_count_min(0)} { 
			set req_index2 $i
			set curr_count_min(0) $filtered_cell_count_per_path($i)
			}	
		}

		echo [format " Minimum levels of logic is : %d" $curr_count_min(0) ]
			
		set my_range [expr {($curr_count_max(0)) - ($curr_count_min(0))}]
        #puts " Range     : $my_range"
        set interval [expr {$my_range/5}]
		set remainder [expr {fmod($my_range,5)}]
		#echo " Remainder : $remainder"
        #puts " Interval  : $interval"
		if {$interval != 0} {
        set max1 [expr {$curr_count_min(0) + $interval}]
        set max2 [expr {$max1 + $interval}]
        set max3 [expr {$max2 + $interval}]
        set max4 [expr {$max3 + $interval}]
        set max5 [expr {$max4 + $interval + $remainder}]
        set string1 "Logic levels $curr_count_min(0) to $max1 "
        set string2 "Logic levels $max1 to $max2 "
        set string3 "Logic levels $max2 to $max3 "
        set string4 "Logic levels $max3 to $max4 "
        set string5 "Logic levels $max4 to $max5 "
        #puts " Max1=$max1 Max2=$max2 Max3=$max3 Max4=$max4 Max5= $max5"
		
		for {set j 0} {$j < $len_of_filtered_arr} {incr j} {
		#puts " count is $filtered_cell_count_per_path($j)"
			if {($max1)>($filtered_cell_count_per_path($j)) && ($filtered_cell_count_per_path($j))>=($curr_count_min(0))} {
			incr count1
			} elseif {($max2)>($filtered_cell_count_per_path($j)) && ($filtered_cell_count_per_path($j))>=($max1)} {
				incr count2
				} elseif {($max3)>($filtered_cell_count_per_path($j)) && ($filtered_cell_count_per_path($j))>=($max2)} {
					incr count3
					} elseif {($max4)>($filtered_cell_count_per_path($j)) && ($filtered_cell_count_per_path($j))>=($max3)} {
						incr count4
						} elseif {($max5)>=($filtered_cell_count_per_path($j)) && ($filtered_cell_count_per_path($j))>=($max4)} {
							incr count5
						}
		}
				
		echo [format " $string1  ------> %2d \n $string2  ------> %2d \n $string3  ------> %2d \n $string4  ------> %2d \n $string5  ------> %2d \n " $count1 $count2 $count3 $count4 $count5]
        echo " ********************************************************************** "
        echo "       Histogram of levels of logic in violating paths"
        echo " ********************************************************************** \n\n"
        echo " In the histogram, each * represents 1 logic level \n\n"
        puts -nonewline "$string1      "

        for {set i 0} {$i < [expr $count1/1]} {incr i} {
            puts -nonewline "*"
        }
        puts "\n"
        puts -nonewline "$string2      "
        for {set j 0} {$j < [expr $count2/1]} {incr j} {
        puts -nonewline "*"
        }
        puts "\n"
        puts -nonewline "$string3      "
        for {set k 0} {$k < [expr $count3/1]} {incr k} {
        puts -nonewline "*"
		}
        puts "\n"
        puts -nonewline "$string4      "
        for {set l 0} {$l < [expr $count4/1]} {incr l} {
        puts -nonewline "*"
        }
        puts "\n"
        puts -nonewline "$string5      "
        for {set m 0} {$m < [expr $count5/1]} {incr m} {
        puts -nonewline "*"
        }
        puts "\n"

		} else {
		set max1 [expr {$curr_count_min(0) + 1}]
        set max2 [expr {$max1 + 1}]
        set max3 [expr {$max2 + 1}]
        set max4 [expr {$max3 + 1}]
        set max5 [expr {$max4 + 1}]
        set string1 "Logic levels $curr_count_min(0) to $max1 "
        set string2 "Logic levels $max1 to $max2 "
        set string3 "Logic levels $max2 to $max3 "
        set string4 "Logic levels $max3 to $max4 "
        set string5 "Logic levels $max4 to $max5 "
		#puts " Max1=$max1 Max2=$max2 Max3=$max3 Max4=$max4 Max5= $max5"
		
		for {set j 0} {$j < $len_of_filtered_arr} {incr j} {
		#puts " count is $filtered_cell_count_per_path($j)"
			if {($max1)>($filtered_cell_count_per_path($j)) && ($filtered_cell_count_per_path($j))>=($curr_count_min(0))} {
			incr count1
			} elseif {($max2)>($filtered_cell_count_per_path($j)) && ($filtered_cell_count_per_path($j))>=($max1)} {
				incr count2
				} elseif {($max3)>($filtered_cell_count_per_path($j)) && ($filtered_cell_count_per_path($j))>=($max2)} {
					incr count3
					} elseif {($max4)>($filtered_cell_count_per_path($j)) && ($filtered_cell_count_per_path($j))>=($max3)} {
						incr count4
						} elseif {($max5)>=($filtered_cell_count_per_path($j)) && ($filtered_cell_count_per_path($j))>=($max4)} {
							incr count5
						}
		}
				
		echo [format " $string1  ------> %2d \n $string2  ------> %2d \n $string3  ------> %2d \n $string4  ------> %2d \n $string5  ------> %2d \n " $count1 $count2 $count3 $count4 $count5]
        echo " ********************************************************************** "
        echo "       Histogram of levels of logic in violating paths"
        echo " ********************************************************************** \n\n"
        echo " In the histogram, each * represents 1 logic level \n\n"
        puts -nonewline "$string1  "

        for {set i 0} {$i < [expr $count1/1]} {incr i} {
            puts -nonewline "*"
        }
        puts "\n"
        puts -nonewline "$string2  "
        for {set j 0} {$j < [expr $count2/1]} {incr j} {
        puts -nonewline "*"
        }
        puts "\n"
        puts -nonewline "$string3  "
        for {set k 0} {$k < [expr $count3/1]} {incr k} {
        puts -nonewline "*"
		}
        puts "\n"
        puts -nonewline "$string4  "
        for {set l 0} {$l < [expr $count4/1]} {incr l} {
        puts -nonewline "*"
        }
        puts "\n"
        puts -nonewline "$string5  "
        for {set m 0} {$m < [expr $count5/1]} {incr m} {
        puts -nonewline "*"
        }
        puts "\n"

		}
		
	

	} else {
	   echo " my_proc : This tcl script prints the logic levels Without BUF/INV levels in violating paths "
	   echo " "
	   echo " Usage   : my_proc -N <N value> -TRSH <TRSH value>"
	   echo " "
       echo " -N      : Max. Number of paths to be considered for get_timing_path "
	   echo " -TRSH   : Threshold for number of logic levels to look for in each path "
       return
	}
	
}