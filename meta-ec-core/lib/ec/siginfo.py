# Based on poky/meta/lib/oe/sstatesig.py

def find_siginfo(pn, taskname, taskhashlist, d):
    """ Find signature data files for comparison purposes """

    import fnmatch
    import glob

    if not taskname:
        # We have to derive pn and taskname
        key = pn
        splitit = key.split('.bb:')
        taskname = splitit[1]
        pn = os.path.basename(splitit[0]).split('_')[0]

    hashfiles = {}
    filedates = {}

    def get_hashval(siginfo):
        if siginfo.endswith('.siginfo'):
            return siginfo.rpartition(':')[2].partition('_')[0]
        else:
            return siginfo.rpartition('.')[2]

    # First search in stamps dir
    localdata = d.createCopy()
    localdata.setVar('MULTIMACH_TARGET_SYS', '*')
    localdata.setVar('PN', pn)
    localdata.setVar('PV', '*')
    localdata.setVar('PR', '*')
    localdata.setVar('EXTENDPE', '')
    stamp = localdata.getVar('STAMP')

    filespec = '%s.%s.sigdata.*' % (stamp, taskname)
    foundall = False
    import glob
    for fullpath in glob.glob(filespec):
        match = False
        if taskhashlist:
            for taskhash in taskhashlist:
                if fullpath.endswith('.%s' % taskhash):
                    hashfiles[taskhash] = fullpath
                    if len(hashfiles) == len(taskhashlist):
                        foundall = True
                        break
        else:
            try:
                filedates[fullpath] = os.stat(fullpath).st_mtime
            except OSError:
                continue
            hashval = get_hashval(fullpath)
            hashfiles[hashval] = fullpath

    if taskhashlist:
        return hashfiles
    else:
        return filedates

bb.siggen.find_siginfo = find_siginfo
