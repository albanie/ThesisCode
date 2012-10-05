## ==============================================================
## File generated by AutoESL - High-Level Synthesis System (C, C++, SystemC)
## Version: 2012.1
## Copyright (C) 2012 Xilinx Inc. All rights reserved.
## 
## ==============================================================

if { [catch {
    source ./settings.tcl
    source ./extraction.tcl

    set cur_dir [file normalize "."]

    if {![info exists pcore_syn]} {
        set pcore_syn 0
    }

    set rtl_syn_dir [file normalize "../../../rtl_synthesis"]
    if { $pcore_syn } {
        if { [file isdirectory $rtl_syn_dir ] } {
            file delete -force $rtl_syn_dir
        }
        file copy -force $cur_dir $rtl_syn_dir
        cd $rtl_syn_dir
    }

    #open a project "project" 
    set project_file project.xise
    if { [file exists $project_file] } {
        project open $project_file
    } else {
        project new $project_file
    }

    project set "Preferred Language" $language

    #config device
    if { [string equal -nocase $family "spartan3adsp"]} {
        set family "spartan-3a dsp"
    }

    project set family $family
    project set device $device
    project set package $package
    project set speed $speed

    #add files into project
    # collect the local .vhd, .v, .ucf and .xco files.

    if { $pcore_syn } {
        set design_files $src_files
    } else {
        set design_files [glob -nocomplain *.v *.vhd *.vhdl *.ucf *.xco]
    }

    foreach file $design_files {
        if { [catch { xfile add $file } err] } {
            puts "$err"
        } else {
            puts "$file added to the project."
        }
    }

    #set top module
    set arch ""
    if { [string equal -nocase $language "vhdl"] } {
        set arch "behav"
        puts "Set top module: $top_module|$arch"
        project set top $arch $top_module
    } else {
        puts "Set top module: $top_module|$arch"
        project set top $top_module
    }

    #options 
    project set "Optimization Goal" $optimization_goal
    project set "Optimization Effort" $optimization_effort
    project set "Register Duplication" $register_duplication -process "Synthesize - XST"
    project set "Register Balancing" $register_balancing
     
    if {[string equal -nocase $par_effort "extra"]} {
        project set "Place & Route Effort Level" high
        project set "Extra Effort (Highest PAR level only)" normal
    } elseif {[string equal -nocase $par_effort "high"]} {
        project set "Place & Route Effort Level" high
    }

    if {[string equal -nocase $add_io_buffers "false"] || $pcore_syn } {
        project set "Add I/O Buffers" False
        project set "Trim Unconnected Signals" False
    }

    # run implementation from synthesis through timing analysis
    puts "Running implementation from synthesis through timing analysis ..."

    # regenerate all cores
    if {[lsearch $design_files *.xco] >= 0} {
        process run "Regenerate All Cores"
    }

    if { $pcore_syn } {
        process run "Synthesize - XST"
    } else {
        process run "Implement Design"
    }

    #close project
    puts "close project ..."
    project close
} result] } {
    puts "@E \[IMPL-249\] Errors occured while synthesizing the design: $result"
    cd $cur_dir
    exit 1
} else {
    if { [file isfile ${top_module}.syr] } {
        set str_err [exec grep "Number of errors" ${top_module}.syr]
        set error_num [lindex $str_err 4]
        if { $error_num >0 } {
            puts "@E \[IMPL-249\] Errors occured while synthesizing the design."
            cd $cur_dir
            exit 1
        }
    } else {
        puts "@E \[IMPL-249\] Errors occured while synthesizing the design."
        cd $cur_dir
        exit 1
    }
    if {$pcore_syn} {
        cd $cur_dir

        ## generate a black box for dut if pcore_lang is verilog
        if {$pcore_lang == "verilog"} {
            set dut_file ${top_module}.v
            set f [open $dut_file r]
            set old_rtl [read $f]
            close $f
            set new_rtl ""
            set re_module {module\s+[^;]+;}
            set re_port {(?:input|output|inout)\s+[^;]+;}
            set m [regexp -inline $re_module $old_rtl]
            set m [lindex $m 0]
            set m "[string range $m 0 end-1]/*synthesis syn_black_box*/;"
            append new_rtl $m "\n"
            foreach m [regexp -all -inline $re_port $old_rtl] {
                append new_rtl $m "\n"
            }
            append new_rtl "endmodule\n"
            set f [open $dut_file w]
            puts $f $new_rtl
            close $f
        }

        ## delete dut src files
        foreach src $src_files {
            if {$src == "${top_module}.v"} {
                # skip the black box
                continue
            }
            if {[file ext $src] == ".xco"} {
                set ip_name [file root [file tail $src]]
                file delete -force ${ip_name}.v
                file delete -force ${ip_name}.vhd
                file delete -force ${ip_name}.coe
            }
            file delete -force $src
        }

        ## copy ngc files
        foreach ngc [glob -nocomplain [file join $rtl_syn_dir *.ngc]] {
            file copy -force $ngc [file join .. .. netlist]
        }

        ## copy rtl simulation models
        if {$pcore_lang == "verilog"} {
            set ext ".v"
        } else {
            set ext ".vhd"
        }
        foreach xco [glob -nocomplain [file join $rtl_syn_dir *.xco]] {
            set rtl [file root $xco]$ext
            file copy -force $rtl [file join .. .. simhdl $pcore_lang]
        }

        ## copy mif files
        foreach mif [glob -nocomplain [file join $rtl_syn_dir *.mif]] {
            file copy -force $mif [file join .. .. simhdl $pcore_lang]
        }

        ## change .mpd file
        set mpd_file [glob -nocomplain ../../data/*.mpd]
        if { [llength $mpd_file] > 0 } {
            # read file
            set mpd_file [lindex $mpd_file 0]
            set f [open $mpd_file r]
            set s [read $f]
            close $f
            # substitute
            set pat "# OPTION STYLE"
            set sub "OPTION STYLE"
            set s [regsub $pat $s $sub]
            set pat "# OPTION RUN_NGCBUILD"
            set sub "OPTION RUN_NGCBUILD"
            set s [regsub $pat $s $sub]
            # write file
            set f [open $mpd_file w]
            puts $f $s
            close $f
        }

        ## change .pao file
        set pao_file [glob -nocomplain ../../data/*.pao]
        if { [llength $pao_file] > 0 } {
            # read file
            set pao_file [lindex $pao_file 0]
            set f [open $pao_file r]
            set s [read $f]
            close $f
            # substitute
            foreach src $src_files {
                if {$src == "${top_module}.v"} {
                    # skip the black box
                    continue
                }
                set ext [file ext $src]
                if {$ext != ".v" && $ext != ".vhd" && $ext != ".xco"} {
                    continue
                }
                set ip_name [file root [file tail $src]]
                set pat "(?n)^synlib \\w+ $ip_name .*$\n"
                set sub ""
                set s [regsub $pat $s $sub]
            }
            # write file
            set f [open $pao_file w]
            puts $f $s
            close $f
        }

        ## change .bbd file
        set ngcs ""
        foreach ngc [glob -nocomplain ${rtl_syn_dir}/*.ngc] {
            lappend ngcs [file tail $ngc]
        }
        set bbd_file [glob -nocomplain ../../data/*.bbd]
        # read file
        set f [open $bbd_file r]
        set s [read $f]
        close $f
        # update
        set pat {\nFiles.*}
        set sub ""
        set s [regsub $pat $s $sub]
        append s "\nFiles\n" [join $ngcs ", "]
        # write file
        set f [open $bbd_file w]
        puts $f $s
        close $f
    } elseif { [catch { compile_reports_ise $top_module $language } err] } {
        puts "@E \[IMPL-251\] Errors occured while compiling report: $err"
        cd $cur_dir
        exit 1
    }
}

# vim:set ts=4 sw=4 et: