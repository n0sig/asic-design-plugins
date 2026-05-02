######################################################################
# Open Design — copy from initial so the source checkpoint stays clean
######################################################################
if {[sizeof_collection [get_blocks -quiet ${DESIGN_NAME}_floorplan]] > 0} {
    remove_block -force [get_blocks ${DESIGN_NAME}_floorplan]
}
copy_block -from ${DESIGN_NAME}_initial -to ${DESIGN_NAME}_floorplan
open_block ${DESIGN_NAME}_floorplan


######################################################################
# Initialize Floorplan
# TODO: Set core dimensions for your design
######################################################################
initialize_floorplan -control_type core \
    -core_offset {10 10 10 10} \
    -shape R \
    -side_length {100 100}


######################################################################
# Place IO Pins
######################################################################
source ../scripts/constraints/io.tcl
place_pins -self

######################################################################
# Connect PG Nets
######################################################################
connect_pg_net -automatic


######################################################################
# Create PG Ring
# TODO: Configure PG ring layers and dimensions for your design
######################################################################
create_pg_ring_pattern pg_ring_pattern \
    -horizontal_layer METAL5 \
    -horizontal_width 2 \
    -horizontal_spacing 1 \
    -vertical_layer METAL6 \
    -vertical_width 2 \
    -vertical_spacing 1

set_pg_strategy pg_ring_strategy \
    -core \
    -pattern {{pattern: pg_ring_pattern} {nets: {VDD VSS}} {offset: {2.5 2.5}}}

compile_pg -strategies pg_ring_strategy -tag pg_ring


######################################################################
# Create PG Mesh
# TODO: Configure PG mesh layers and pitch for your design
######################################################################
create_pg_mesh_pattern pg_mesh_pattern \
    -layers {
        {{horizontal_layer: METAL3} {width: 1.0} {spacing: 1.0} {pitch: 20} {offset: 10}} \
        {{vertical_layer: METAL4} {width: 1.0} {spacing: 1.0} {pitch: 30} {offset: 15}}
    }

set_pg_strategy pg_mesh_strategy \
    -core \
    -extension {stop: outermost_ring} \
    -pattern {{pattern: pg_mesh_pattern} {nets: {VDD VSS}}}

compile_pg -strategies pg_mesh_strategy -tag pg_mesh


######################################################################
# Create PG Standard Cell Rail Connections (METAL1)
######################################################################
create_pg_std_cell_conn_pattern std_cell_rail \
    -layers {METAL1} \
    -rail_width {0.5 0.5}

set_pg_strategy std_cell_strategy \
    -core \
    -extension {stop: outermost_ring} \
    -pattern {{pattern: std_cell_rail} {nets: VDD VSS}}

compile_pg -strategies std_cell_strategy -tag pg_rail


######################################################################
# Set Routing Layers
######################################################################
set_ignored_layers -min_routing_layer METAL1 -max_routing_layer METAL6


######################################################################
# Save Floorplan
######################################################################
save_block
save_lib
