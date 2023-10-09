DESCRIPTION = "A recipe doing nothing just to test env-config bootstrap"
PN = "null"
PV = "1"

# Remove base-files from configure dependencies
do_configure[depends] = ""
