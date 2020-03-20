# List all current designs
set this_design [ list_designs ]

# If there are existing designs reset/remove them
if { $this_design != 0 } {
  # To reset the earlier designs
  reset_design
  remove_design -designs
}

if { ! [ info exists top_design ] } {
   set top_design asic_fifo
}

lappend search_path "/pkgs/synopsys/2016/libs/SAED32_EDK/lib/stdcell_hvt/db_nldm"
lappend search_path "/pkgs/synopsys/2016/libs/SAED32_EDK/lib/stdcell_rvt/db_nldm"
lappend search_path "/pkgs/synopsys/2016/libs/SAED32_EDK/lib/stdcell_lvt/db_nldm"
lappend search_path "/pkgs/synopsys/2016/libs/SAED32_EDK/lib/io_std/db_nldm"
lappend search_path "/pkgs/synopsys/2016/libs/SAED32_EDK/lib/sram/db_nldm"

set synthetic_library dw_foundation.sldb

# Changed to only be the slow corner libraries
#set target_library "saed32hvt_ss0p75v125c.db saed32lvt_ss0p75v125c.db saed32rvt_ss0p75v125c.db"
# enable the lvt and rvt library for now at the slow corner
set target_library "saed32lvt_ss0p75v125c.db saed32rvt_ss0p75v125c.db"

# Changed to only be the slow corner libraries
set link_library [join "$target_library * saed32hvt_ss0p75v125c.db saed32io_wb_ss0p95v125c_2p25v.db saed32sram_ss0p95v125c.db dw_foundation.sldb" ]
#set tlu_dir /pkgs/synopsys/2016/libs/SAED32_EDK/tech/star_rcxt/
#set_tlu_plus_files  -max_tluplus $tlu_dir/saed32nm_1p9m_Cmax.tluplus  \
#	            -min_tluplus $tlu_dir/saed32nm_1p9m_Cmin.tluplus  \
#		    -tech2itf_map  $tlu_dir/saed32nm_tf_itf_tluplus.map

# Remove any existing MW direotory
#exec rm -rf ${top_design}.mw
#creating milky way library and linking physical information of the cell 
#set mw_lib ""
#lappend mw_lib /pkgs/synopsys/2016/libs/SAED32_EDK/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m
#lappend mw_lib /pkgs/synopsys/2016/libs/SAED32_EDK/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m
#lappend mw_lib /pkgs/synopsys/2016/libs/SAED32_EDK/lib/stdcell_hvt/milkyway/saed32nm_hvt_1p9m
#lappend mw_lib /pkgs/synopsys/2016/libs/SAED32_EDK/lib/io_std/milkyway/saed32_io_wb
#lappend mw_lib /pkgs/synopsys/2016/libs/SAED32_EDK/lib/sram/milkyway/SRAM32NM

#set tf_dir "/pkgs/synopsys/2016/libs/SAED32_EDK/tech/milkyway/"
#set tlu_dir /pkgs/synopsys/2016/libs/SAED32_EDK/tech/star_rcxt/
#set_tlu_plus_files  -max_tluplus $tlu_dir/saed32nm_1p9m_Cmax.tluplus  \
#                    -min_tluplus $tlu_dir/saed32nm_1p9m_Cmin.tluplus  \
#                    -tech2itf_map  $tlu_dir/saed32nm_tf_itf_tluplus.map
#create_mw_lib ${top_design}.mw -technology $tf_dir/saed32nm_1p9m_mw.tf  -mw_reference_library $mw_lib -open


read_ddc ../outputs/${top_design}.dc.ddc
source -echo -verbose ../../constraints/${top_design}.sdc
#read_verilog ../outputs/${top_design}.dc.vg
