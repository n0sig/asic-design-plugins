######################################################################
# Fusion Compiler Setup
######################################################################
set DESIGN_NAME                     "__DESIGN_NAME__"

set PROJECT_PATH                    "__PROJECT_PATH__"

set LIBRARY_PATH                    "__LIBRARY_PATH__"


######################################################################
# Logical Library Settings
######################################################################
set SEARCH_PATH                     "__DB_DIR__ \
                                    __SDB_DIR__ \
                                    ${PROJECT_PATH}/hdl \
                                    ${PROJECT_PATH}/fc/scripts \
                                    ${PROJECT_PATH}/fc/report \
                                    ${PROJECT_PATH}/fc/output"

set TARGET_LIBRARY                  "__TARGET_LIBRARY__"

set LINK_LIBRARY                    "* $TARGET_LIBRARY"

set SYMBOL_LIBRARY                  "__SYMBOL_LIBRARY__"

set_app_var search_path             "$SEARCH_PATH"

set target_library                  "$TARGET_LIBRARY"

set link_library                    "$LINK_LIBRARY"

set symbol_library                  "$SYMBOL_LIBRARY"


######################################################################
# Physical Library Settings (NDM)
######################################################################
set NDM_REFERENCE_LIB               "__NDM_REFERENCE_LIB__"

set NDM_REFERENCE_LIB_PHY_ONLY      "__NDM_REFERENCE_LIB_PHY_ONLY__"

set TECH_FILE                       "__TECH_FILE__"

set MAX_TLUPLUS_FILE                "__MAX_TLUPLUS_FILE__"

set TYP_TLUPLUS_FILE                "__TYP_TLUPLUS_FILE__"

set MIN_TLUPLUS_FILE                "__MIN_TLUPLUS_FILE__"

set TLUPLUS_MAP_FILE                "__TLUPLUS_MAP_FILE__"


######################################################################
# Design Library Path
######################################################################
set DESIGN_LIBRARY "${PROJECT_PATH}/fc/${DESIGN_NAME}.dlib"


######################################################################
# Host Options
######################################################################
set_host_options -max_cores 32


######################################################################
# Verify Settings
######################################################################
echo "\n=================================================================="
echo "\nFusion Compiler Library Settings:"
echo "design_library:          $DESIGN_LIBRARY"
echo "search_path:             $search_path"
echo "target_library:          $target_library"
echo "link_library:            $link_library"
echo "symbol_library:          $symbol_library"
echo "ndm_reference_lib:       $NDM_REFERENCE_LIB"
echo "\n=================================================================="
