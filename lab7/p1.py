import numpy as np

def chos(vs0, vi0, ve0, sw, iw, ew):
    sc = np.zeros(5, dtype = np.int32)
    for i0 in list(range(5)):
        sc[i0] = sw*vs0[i0] + iw*vi0[i0] + ew*ve0[i0]
    n0 = 0
    for i1 in list(range(1, 5)):
        if(sc[i1] > sc[n0]):
            n0 = i1
    return n0

def wfv(fn, vi): # write file, fn: file name, vi: input vector
    f0 = open(fn, 'w')
    for i0 in list(range(len(vi))):
        f0.write(str(vi[i0]))
        f0.write('\n')
    f0.close()

def wfv2(f0, vi):
    for i0 in list(range(len(vi))):
        f0.write(str(vi[i0]))
        f0.write('\n')

pnum = 6000 # pattern number
inum = 100 # iteration number
np.random.seed(315)
f0 = open("data_ans.txt", 'w')
fn = open("data_n.txt", 'w')
fs = open("data_s.txt", 'w')
fi = open("data_i.txt", 'w')
fe = open("data_e.txt", 'w')
fsw = open("data_sw.txt", 'w')
fiw = open("data_iw.txt", 'w')
few = open("data_ew.txt", 'w')

for i0 in list(range(inum)):
    vn = np.random.randint(0, 32, size = pnum)
    vs = np.random.randint(0, 256, size = pnum)
    vi = np.random.randint(0, 256, size = pnum)
    ve = np.random.randint(0, 256, size = pnum)
    vsw = np.random.randint(0, 8, size = pnum - 4)
    viw = np.random.randint(0, 8, size = pnum - 4)
    vew = np.random.randint(0, 8, size = pnum - 4)

    if(i0 == 0):
        vn[0:6] = [19, 0, 28, 15, 3, 2]
        vs[0:6] = [115, 169, 90, 113, 196, 123]
        vi[0:6] = [141, 113, 78, 147, 113, 141]
        ve[0:6] = [185, 63, 145, 189, 53, 183]
        vsw[0:2] = [3, 1]
        viw[0:2] = [6, 7]
        vew[0:2] = [4, 4]

    # print(vn[0:10], len(vn))
    wfv2(fn, vn)
    wfv2(fs, vs)
    wfv2(fi, vi)
    wfv2(fe, ve)
    wfv2(fsw, vsw)
    wfv2(fiw, viw)
    wfv2(few, vew)

    vn0 = np.array([vn[0], vn[1], vn[2], vn[3], vn[4]])
    vs0 = np.array([vs[0], vs[1], vs[2], vs[3], vs[4]])
    vi0 = np.array([vi[0], vi[1], vi[2], vi[3], vi[4]])
    ve0 = np.array([ve[0], ve[1], ve[2], ve[3], ve[4]])

    for i1 in list(range(pnum - 4)):
        n0 = chos(vs0, vi0, ve0, vsw[i1], viw[i1], vew[i1])
        f0.write(str(n0))
        f0.write(' ')
        f0.write(str(vn0[n0]))
        f0.write('\n')
        if(i1 < pnum - 5):
            vn0[n0] = vn[i1 + 5]
            vs0[n0] = vs[i1 + 5]
            vi0[n0] = vi[i1 + 5]
            ve0[n0] = ve[i1 + 5]

f0.close()
fn.close()
fs.close()
fi.close()
fe.close()
fsw.close()
fiw.close()
few.close()