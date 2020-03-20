#   Title:       my_proc_1.tcl
#
#	Description: This Tcl procedure generates specific outputs given user input.
# 	INPUTS:
#	 			N 	 - 	Max. Number of paths to be considered for get_timing_path
#		 	
#	OUTPUTS:
#               * histogram of slacks in violating paths
#	   
#   Options:   	-N  	   Max. Number of paths
#		
#
#	Usage:       prompt> source ../scripts/my_proc_1.tcl
#					   > my_proc_1 -help
#					   > my_proc_1 -N 20
#
#	Author:     Pooja Gopalakrishnan
proc my_proc_1 args {
   #suppress_message UID-101
   ################################################
   # Parse the user inputs

   set option_N [lindex $args 0] 
   set value_N [lindex $args 1] 

  #--------------------------------------------------
   if {[string match -help* $option_N]} {
       echo " my_proc_1 : This tcl script prints a * histogram of slacks in violating paths "
	   echo " "
	   echo " Usage   : my_proc_1 -N <N value>"
	   echo " "
       echo " -N      : Max. Number of paths to be considered for get_timing_path "
       return
   	} elseif {[string match -N* $option_N]} { 
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
		array set values {}
		array set curr_count_max {}
		set curr_count_max(0) -1
		array set curr_count_min {}
		set curr_count_min(0) 0
		set count1 0
        set count2 0
        set count3 0
        set count4 0
        set count5 0
		#----------------------------------------------------------------------------------------------------------
		for {set i 0} {$i < $N} {incr i} {
			set path [index_collection [get_timing_paths -max_paths $N -slack_lesser_than 0] $i]
			set values($i) [get_attribute $path slack]
			#echo "path is $path slack is $values($i)"
			}
		set len_of_arr [array size values]
		for {set i 0} {$i < $len_of_arr} {incr i} {
			
			if {($values($i)) > ($curr_count_max(0)) } { 
			set curr_count_max(0) $values($i)
			}
		}
		echo " "
		echo [format " Maximum slack is :%2s " $curr_count_max(0) ]
		
		set curr_count_min(0) $curr_count_max(0)
		
		for {set i 0} { $i < $len_of_arr} {incr i} {
			
			if {$values($i) < $curr_count_min(0)} { 
			set curr_count_min(0) $values($i)
			}	
		}
		echo [format " Minimum slack is :%2s " $curr_count_min(0) ]
		echo " "
		set my_range [expr {($curr_count_max(0)) - ($curr_count_min(0))}]
        #puts " Range : $my_range"
        set interval [expr {$my_range/5.0}]
        #puts " Interval : $interval"
                set max1 [expr {$curr_count_min(0) + $interval}]
                set max2 [expr {$max1 + $interval}]
                set max3 [expr {$max2 + $interval}]
                set max4 [expr {$max3 + $interval}]
                set max5 [expr {$max4 + $interval}]
                set string1 "Slack $max1 to $curr_count_min(0)"
                set string2 "Slack $max2 to $max1"
                set string3 "Slack $max3 to $max2"
                set string4 "Slack $max4 to $max3"
                set string5 "Slack $max5 to $max4"
                #puts " Max1=$max1 Max2=$max2 Max3=$max3 Max4=$max4 Max5= $max5"
		for {set j 0} {$j < $len_of_arr} {incr j} {
		#puts " count is $values($j)"
			if {($max1)>($values($j)) && ($values($j))>=($curr_count_min(0))} {
			incr count1
			} elseif {($max2)>($values($j)) && ($values($j))>=($max1)} {
				incr count2
				} elseif {($max3)>($values($j)) && ($values($j))>=($max2)} {
					incr count3
					} elseif {($max4)>($values($j)) && ($values($j))>=($max3)} {
						incr count4
						} elseif {($max5)>=($values($j)) && ($values($j))>=($max4)} {
							incr count5
						}
		}
				
		echo [format " $string1    ------> %2s \n $string2  ------> %2s \n $string3  ------> %2s \n $string4  ------> %2s \n $string5   ------> %2s \n " $count1 $count2 $count3 $count4 $count5]
		
        echo " ********************************************************************** "
                echo "          Histogram of slacks in violating paths"
                echo " ********************************************************************** \n\n"
                echo " In the histogram, each * represents 5 violating paths \n\n"
                puts -nonewline "$string1     "
        for {set i 0} {$i < [expr $count1/5]} {incr i} {
                puts -nonewline "*"
                }
        puts "\n"
                puts -nonewline "$string2   "
                for {set j 0} {$j < [expr $count2/5]} {incr j} {
                puts -nonewline "*"
                }
        puts "\n"
                puts -nonewline "$string3   "
                for {set k 0} {$k < [expr $count3/5]} {incr k} {
                puts -nonewline "*"
		}
        puts "\n"
                puts -nonewline "$string4   "
                for {set l 0} {$l < [expr $count4/5]} {incr l} {
                puts -nonewline "*"
                }
        puts "\n"
                puts -nonewline "$string5    "
                for {set m 0} {$m < [expr $count5/5]} {incr m} {
                puts -nonewline "*"
                }
        puts "\n"

		} else {
	   echo " my_proc_1 : This tcl script prints a * histogram of slacks in violating paths "
	   echo " "
	   echo " Usage   : my_proc_1 -N <N value>"
	   echo " "
       echo " -N      : Max. Number of paths to be considered for get_timing_path "
       return
	}
	
}