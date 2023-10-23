addtask showdata
do_showdata[nostamp] = "1"
python do_showdata() {
    # emit variables and shell functions
    bb.data.emit_env(sys.__stdout__, d, True)
    # emit the metadata which isn't valid shell
    for e in bb.data.keys(d):
        if d.getVarFlag(e, "python", False):
            bb.plain("\npython %s () {\n%s}" % (e, d.getVar(e)))
}

addtask listtasks
do_listtasks[nostamp] = "1"
python do_listtasks() {
    bb.plain("")
    for e in bb.data.keys(d):
        if d.getVarFlag(e, "task", False):
            flags = d.getVarFlags(e)
            bb.plain('Task: \"{}\"'.format(e))
            bb.plain("Flags: {}".format(json.dumps(flags, indent=2)))
            bb.plain("")
}
