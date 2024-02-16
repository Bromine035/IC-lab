import numpy as np

def ee(a, b):
    if(b == 0):
        return (a, 1, 0)
    (d1, s1, t1) = ee(b, a%b)
    d0 = d1
    s0 = t1
    t0 = s1 - int(a/b)*t1
    print("check: ", d0, s0, t0)
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


print(ee(64, 43))


