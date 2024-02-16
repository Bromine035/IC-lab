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



# print("hello lab6")
# print(ee(60, 13))

pnum = 100000 # pattern number
vp = lp(128)
np.random.seed(315)
f0 = open("data_inv.txt", 'w')
f0.write("5 1 1\n")
f0.write("5 2 3\n")
f0.write("5 3 2\n")
f0.write("5 4 4\n")
# f0.write("60 13 5\n")
for i0 in list(range(pnum)):
    n0 = vp[np.random.randint(2, len(vp))]
    n1 = np.random.randint(1, n0)
    (nd, ns, nt) = ee(n1, n0)
    if(ns < 0):
        nss = ns + n0
    else:
        nss = ns
    if(np.random.randint(0, 2) == 0):
        f0.write(str(n0))
        f0.write(' ')
        f0.write(str(n1))
    else:
        f0.write(str(n1))
        f0.write(' ')
        f0.write(str(n0))
    f0.write(' ')
    f0.write(str(nss))
    f0.write('\n')

f0.close()
