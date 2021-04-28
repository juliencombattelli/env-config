die() {
    bbfatal "$*"
}

addtask showdata
do_showdata[nostamp] = "1"
python do_showdata() {
    import sys
    # emit variables and shell functions
    bb.data.emit_env(sys.__stdout__, d, True)
    # emit the metadata which isn't valid shell
    for e in bb.data.keys(d):
        if d.getVarFlag(e, 'python', False):
            bb.plain("\npython %s () {\n%s}" % (e, d.getVar(e)))
}

addtask listtasks
do_listtasks[nostamp] = "1"
python do_listtasks() {
    import sys
    for e in bb.data.keys(d):
        if d.getVarFlag(e, 'task', False):
            bb.plain("%s" % e)
}
