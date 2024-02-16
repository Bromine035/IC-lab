import numpy as np

def ee(a, b):
    if(b == 0):
        return (a, 1, 0)
    (d1, s1, t1) = ee(b, a%b)
    d0 = d1
    s0 = t1
    t0 = s1 - int(a/b)*t1
    # print("check: ", d0, s0, t0)
    return (d0, s0, t0)

def lp(ni): # list prinme numbers < ni
    if(ni < 3):
        return np.array([])
    elif(ni == 3):
        return np.array([2])
    else:
        v0 = [2]
        for i0 in list(range(3, ni)):
            ok0 = True
            for i1 in v0:
                if i0%i1 == 0:
                    ok0 = False
            if(ok0):
                v0.append(i0)
        return np.array(v0)

pnum = 100000 # pattern number
vp = lp(64)
np.random.seed(315)
f0 = open("data_ec.txt", 'w')
f0.write("5 1 5 1 17 2 6 3\n")
for i0 in list(range(pnum)):
    npm = vp[np.random.randint(2, len(vp))]
    npx = np.random.randint(0, npm)
    na = np.random.randint(0, npm)
    addi = np.random.choice([True, False])
    if(addi):
        npy = np.random.randint(0, npm)
        nqx = np.random.randint(0, npm)
        nqy = np.random.randint(0, npm)
        while(nqx == npx):
            nqx = np.random.randint(0, npm)
        (nd0, ns0, nt0) = ee((nqx - npx), npm)
        if(ns0 < 0):
            ns0 += npm
        ns = ((nqy - npy)*ns0)%npm
    else:
        npy = np.random.randint(1, npm)
        nqx = npx
        nqy = npy
        (nd0, ns0, nt0) = ee(2*npy, npm)
        if(ns0 < 0):
            ns0 += npm
        ns = ((3*npx**2 + na)*ns0)%npm
    nrx = (ns**2 - npx - nqx)%npm
    nry = (ns*(npx - nrx) - npy)%npm
    if(nrx < 0):
        nrx = nrx + npm
    if(nry < 0):
        nry = nry + npm
    f0.write(str(npx))
    f0.write(' ')
    f0.write(str(npy))
    f0.write(' ')
    f0.write(str(nqx))
    f0.write(' ')
    f0.write(str(nqy))
    f0.write(' ')
    f0.write(str(npm))
    f0.write(' ')
    f0.write(str(na))
    f0.write(' ')
    f0.write(str(nrx))
    f0.write(' ')
    f0.write(str(nry))
    f0.write('\n')
f0.close()
