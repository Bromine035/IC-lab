import numpy as np

def invb(ni): # inverter of 1 binary number
    no = ni
    for i0 in list(range(len(ni))):
        if(ni[i0] == 0):
            no[i0] = 1
        elif(ni[i0] == 1):
            no[i0] = 0
        else:
            no[i0] = -1
    return no

def addb(n0, n1): # adder of 2 binary numbers
    cout = 0
    if(len(n0) > len(n1)):
        no = n0
    else:
        no = n1
    for i0 in list(range(len(n0))):
        if(n0[i0] + n1[i0] + cout == 3):
            cout = 1
            no[i0] = 1
        elif(n0[i0] + n1[i0] + cout == 2):
            cout = 1
            no[i0] = 0
        elif(n0[i0] + n1[i0] + cout == 1):
            cout = 0
            no[i0] = 1
        elif(n0[i0] + n1[i0] + cout == 0):
            cout = 0
            no[i0] = 0
        else:
            cout = -1
            no[i0] = -1
    return no

def dtob(di, nb): # decimal to binary
    if(di < 0):
        sok = True
        ni = -di
    else:
        sok = False
        ni = di
    no = np.zeros(nb, dtype = int)
    one = np.zeros(nb, dtype = int)
    one[0] = 1
    for i0 in list(range(nb)):
        if(ni < 2):
            no[i0] = ni
            break
        else:
            no[i0] = ni%2
            ni = int(ni/2)
    if(sok):
        no = addb(invb(no), one)
    return no

def btos(ni): # binary to string
    s0 = ""
    for i0 in list(range(len(ni))):
        s0 += str(ni[len(ni) - 1 - i0])
    return s0

def showv(ni): # print a vector (binary number order)
    for i0 in list(range(len(ni))):
        print(ni[len(ni)-1-i0], end = ' ')
    print("")

def ftob(fi): # float to binary (IEEE floating number IP)
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # !!!!!!!!  Here we may have an error on the last bit of fraction  !!!!!!!
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    n0 = 1
    no = np.zeros(32, dtype = int)
    if(fi < 0):
        no[31] = 1
        f0 = -fi
    else:
        no[31] = 0
        f0 = fi
    for i0 in list(range(0, 255)):
        if f0*(2**i0) <= 2 and f0*(2**i0) > 1 :
            no[23:31] = dtob(127 - i0, 8) # wrong !!! it shoild unsigned
            # print("check dtob: ", dtob(127 - i0, 8), " no[23:31]: ", no[23:31])
            f0 = f0*(2**i0)
    for i1 in list(range(1, 24)):
        if(n0 + 2**(-i1) <= f0):
            n0 += 2**(-i1)
            no[23 - i1] = 1
        # print("check n0: ", n0, " f0: ", f0, " n0 + 2**(-i1): ", n0 + 2**(-i1))
    return no

def lk_relu(mi): # leaky ReLU
    mo = mi
    for i0 in list(range(len(mi))):
        for i1 in list(range(len(mi[0]))):
            if(mi[i0][i1] < 0):
                mo[i0][i1] = 0.1 * mi[i0][i1]
            else:
                pass
    return mo

def sigm(mi): # Sigmoid
    mo = mi
    for i0 in list(range(len(mi))):
        for i1 in list(range(len(mi[0]))):
            if(mi[i0][i1] < 0):
                mo[i0][i1] = 1/(1 + np.exp(-mi[i0][i1]))
            else:
                pass
    return mo

def unie(mi, emin, emax): # uniformlize the exponents
    mo = mi
    for i0 in list(range(len(mi))):
        for i1 in list(range(len(mi[0]))):
            mo[i0][i1] = mo[i0][i1]*(10**(np.random.randint(emin, emax+1)))
            print(np.random.randint(emin, emax+1), end = ' ')
    return mo

# n0 = 10
# # showv(dtob(n0, 32))
# print(btos(dtob(n0, 32)))
# n1 = 0.08721975
# # showv(ftob(n1))
# print(btos(ftob(n1)))
# m0 = np.random.rand(3, 1)
# print(m0)
# print(m0[1][0])
# m0 = np.array([[1, 2],
#                [3, 4]])
# m1 = np.array([[5, 6],
#                [7, 8]])
# print(m0@m1)
# f0 = open("./test.txt", 'w')
# f0.write(btos(dtob(n0, 32)))
# f0.write('\n')
# f0.write(btos(ftob(n1)))
# f0.write('\n')
# f0.close()

fu = open("./lab04_weight_u.txt", 'w')
fw = open("./lab04_weight_w.txt", 'w')
fv = open("./lab04_weight_v.txt", 'w')
fx = open("./lab04_data_x.txt", 'w')
fh = open("./lab04_data_h.txt", 'w')
fy = open("./lab04_data_y.txt", 'w')

np.random.seed(315)
emin = -7 # min exponents number as [10^emin, 10^emax]
emax = 3  # max exponents number as [10^emin, 10^emax]
ptnum = int(input("please enter pattern number: "))
for i0 in list(range(ptnum)):
    mu = unie(np.random.rand(3, 3)*2 - 1, emin, emax)
    mw = unie(np.random.rand(3, 3)*2 - 1, emin, emax)
    mv = unie(np.random.rand(3, 3)*2 - 1, emin, emax)
    mx1 = unie(np.random.rand(3, 1)*2 - 1, emin, emax)
    mx2 = unie(np.random.rand(3, 1)*2 - 1, emin, emax)
    mx3 = unie(np.random.rand(3, 1)*2 - 1, emin, emax)
    mh = unie(np.random.rand(3, 1)*2 - 1, emin, emax)
    h1 = lk_relu(mu@mx1 + mw@mh)
    h2 = lk_relu(mu@mx2 + mw@h1)
    h3 = lk_relu(mu@mx3 + mw@h2)
    y1 = sigm(mv@h1)
    y2 = sigm(mv@h2)
    y3 = sigm(mv@h3)

    # print("check u: ", mu)
    # print("check w: ", mw)
    # print("check v: ", mv)
    # print("check x1: ", mx1)
    # print("check x2: ", mx2)
    # print("check x3: ", mx3)
    # print("check h0: ", mh)
    # print("check h1: ", h1)
    # print("check h2: ", h2)
    # print("check h3: ", h3)
    # print("check y1: ", y1)
    # print("check y2: ", y2)
    # print("check y3: ", y3)
    # print("check u01: ", mu[0][1])

    # print("binary check h0[1]: ", btos(ftob(mh[1][0])))
    # print("binary check u01: ",   btos(ftob(mu[0][1])))
    # print("binary check x1[1]: ", btos(ftob(mx1[1][0])))
    # print("binary check x2[2]: ", btos(ftob(mx2[2][0])))
    # print("binary check x3[0]: ", btos(ftob(mx3[0][0])))
    # print("binary check y1[1]: ", btos(ftob(y1[1][0])))
    # print("binary check y2[2]: ", btos(ftob(y2[2][0])))
    # print("binary check y3[0]: ", btos(ftob(y3[0][0])))
    
    for i1 in list(range(3)):
        for i2 in list(range(3)):
            # fu.write(btos(ftob(mu[i1][i2])))
            # fw.write(btos(ftob(mw[i1][i2])))
            # fv.write(btos(ftob(mv[i1][i2])))
            fu.write(str(mu[i1][i2]))
            fw.write(str(mw[i1][i2]))
            fv.write(str(mv[i1][i2]))
            fu.write('\n')
            fw.write('\n')
            fv.write('\n')
        fh.write(str(mh[i1][0]))
        fx.write(str(mx1[i1][0]))
        fy.write(str(y1[i1][0]))
        fh.write('\n')
        fx.write('\n')
        fy.write('\n')
    for i3 in list(range(3)):
        # fx.write(btos(ftob(mx2[i3])))
        # fy.write(btos(ftob(y2[i3])))
        fx.write(str(mx2[i3][0]))
        fy.write(str(y2[i3][0]))
        fx.write('\n')
        fy.write('\n')
    for i4 in list(range(3)):
        fx.write(str(mx3[i4][0]))
        fy.write(str(y3[i4][0]))
        fx.write('\n')
        fy.write('\n')
print("hello lab04")

fu.close()
fw.close()
fv.close()
fx.close()
fh.close()
fy.close()
