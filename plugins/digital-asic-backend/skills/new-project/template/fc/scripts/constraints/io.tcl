######################################################################
# IO Pin Placement
# TODO: Define pin placement for your design
# Use /modify-floorplan skill to generate pin placement
######################################################################

######################################################################
# Helper proc: place one port
######################################################################
proc place_port {name layer side offset width} {
    set_individual_pin_constraints -ports [get_ports $name] \
        -allowed_layers [list $layer] \
        -sides          [list $side] \
        -offset         $offset \
        -width          $width
}

######################################################################
# Helper proc: place a group of pins with evenly spaced offsets
#   pins   — list of pin names
#   side   — edge number (1=bottom, 2=top, 3=right, 4=left)
#   start  — offset of the first pin
#   step   — offset increment per pin (negative to count backwards)
#   width  — pin width
#   layers — list of layers to cycle through (e.g. {METAL2 METAL4})
######################################################################
proc place_pin_group {pins side start step width layers} {
    set nlayers [llength $layers]
    set idx 0
    foreach pin $pins {
        set offset [expr {$start + $idx * $step}]
        set layer  [lindex $layers [expr {$idx % $nlayers}]]
        place_port $pin $layer $side $offset $width
        incr idx
    }
}

# TODO: Add pin placement commands here
# Example:
# place_port clk METAL3 3 20.0 0.3
# place_port rst_n METAL3 3 25.0 0.3
