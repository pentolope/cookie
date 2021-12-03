package require cmdline
package require struct::matrix
package require report

proc report_levels_of_logic { args } {

    set options {
        { "less_than.arg" "" "Limit to paths with less than this number" }
        { "greater_than.arg" "" "Limit to paths with greater than this number" }
        { "file.arg" "" "Output file name" }
        
    }
    array set opts [::cmdline::getKnownOptions args $options]

    # Ensure that the procedure is called with some arguments
    if { [string equal "" $opts(less_than)] && [string equal "" $opts(greater_than)] } {
        post_message -type warning "You must specify a numeric value\
            for -less_than or -greater_than"
        return
    }
    
    # Ensure that the procedure is called with numeric argument values
    if { ![string is double $opts(less_than)] } {
        post_message -type warning "You must specify a numeric value\
            for -less_than"
        return
    }
    if { ![string is double $opts(greater_than)] } {
        post_message -type warning "You must specify a numeric value\
            for -greater_than"
        return
    }
    
    # Create a matrix to hold information about the failing paths
    set logic_levels_matrix [::struct::matrix]
    $logic_levels_matrix add columns 4

    # Pass all unknown arguments straight to get_timing_paths
    if { [catch { eval get_timing_paths $args } paths_col] } {
        post_message -type error $paths_col
        return
    }
    
    # Walk through the list of timing paths, getting information
    # about the levels of logic
    foreach_in_collection path_obj $paths_col {
    
        # Assume the path will be reported, unless the number of levels of
        # logic is outside the specified bounds.
        set include_path 1
        
        # How many levels of logic are there in the path?
        set levels_of_logic [get_path_info -num_logic_levels $path_obj]
        
        # If we specified a lower bound, we do not report the path if the
        # levels of logic are greater than or equal to the lower bound
        if { ! [string equal "" $opts(less_than)] } {
            if { $levels_of_logic >= $opts(less_than) } {
                set include_path 0
            }
        }
        
        # If we specified an upper bound, we do not report the path if the
        # levels of logic are less than or equal to the upper bound
        if { ! [string equal "" $opts(greater_than)] } {
            if { $levels_of_logic <= $opts(greater_than) } {
                set include_path 0
            }
        }
        
        # If the path has levels of logic that fall within our bounds,
        # report on it
        if { $include_path } {
        
            $logic_levels_matrix add row [list \
                $levels_of_logic \
                [get_path_info -slack $path_obj] \
                [get_node_info -name [get_path_info -from $path_obj]] \
                [get_node_info -name [get_path_info -to $path_obj]] ]
        }
    }
    # Finished going through all the paths from get_timing_paths
    
    # If there are any rows in the matrix, paths match the criteria.
    # We have to print out the table with that information.
    if { 0 == [$logic_levels_matrix rows] } {
    
        # No paths meet the criteria
        # Print out a quick message
        post_message "No paths meet the criteria to report levels of logic"
        
        # If there is an error opening the file, print a message saying
        # that. Otherwise, say there are no paths meeting the criteria
        if { ! [string equal "" $opts(file)] } {
            if { [catch { open $opts(file) w } fh] } {
                post_message -type error "Couldn't open file: $fh"
            } else {
                puts $fh "No paths meet the criteria to report levels of logic"
                catch { close $fh }
            }
        }
    
    } else {
    
        # Put in the header row
        $logic_levels_matrix insert row 0 \
            [list "Levels of logic" "Slack" "From" "To"]
    
        # We need a style defined to print out the table of results
        catch { ::report::rmstyle basicrpt }
        ::report::defstyle basicrpt {{cap_rows 1}} {
            data        set [split "[string repeat "; "   [columns]];"]
            top         set [split "[string repeat "+ - " [columns]]+"]
            bottom      set [top get]
            topcapsep   set [top get]
            topdata     set [data get]
            top         enable
            topcapsep   enable
            bottom      enable
            tcaption    $cap_rows
        }
        
        # Create the report, set the columns to have one space of padding, and
        # print out the matrix with the specified format
        catch { r destroy }
        ::report::report r 4 style basicrpt
        for { set col 0 } { $col < [r columns]} { incr col } {
            r pad $col both " "
        }
        # post_message "Levels of logic\n[r printmatrix $logic_levels_matrix]"
        
        # Save the report to a file if a file name is specified
        if { ! [string equal "" $opts(file)] } {
            if { [catch { open $opts(file) w } fh] } {
                post_message -type error "Couldn't open file: $fh"
            } else {
                puts $fh "Levels of logic"
                r printmatrix2channel $logic_levels_matrix $fh
                catch { close $fh }
            }
        }
    }
}

report_levels_of_logic -setup -greater_than 8 -npaths 2000 -file levels1.txt
