#
# Copyright OpenEmbedded Contributors
#
# SPDX-License-Identifier: MIT
#

##
## Purpose:
## This class is used to update the list of crates in SRC_URI
## by reading Cargo.lock in the source tree.
##
## See meta/recipes-devtools/python/python3-bcrypt_*.bb for an example
##
## To perform the update: bitbake -c update_crates recipe-name

addtask do_update_crates after do_patch
do_update_crates[depends] = "python3-native:do_populate_sysroot"

do_update_crates() {
    nativepython3 - <<EOF

def get_crates(f):
    import tomllib
    c_list = 'SRC_URI += " \\ \n'
    crates = tomllib.load(open(f, 'rb'))
    for c in crates['package']:
        if 'source' in c and 'crates.io' in c['source']:
            c_list += "        crate://crates.io/{}/{} \\ \n".format(c['name'], c['version'])
    c_list += '"\n'
    return c_list

import os
crates = "# Autogenerated with 'bitbake -c update_crates ${PN}'\n\n"
for root, dirs, files in os.walk('${S}'):
    for file in files:
        if file == 'Cargo.lock':
            crates += get_crates(os.path.join(root, file))
open(os.path.join('${THISDIR}', '${PN}'+"-crates.inc"), 'w').write(crates)

EOF
}