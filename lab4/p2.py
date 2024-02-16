import numpy as np

def lk_relu(mi): # leaky ReLU
    mo = mi
    for i0 in list(range(len(mi))):
        for i1 in list(range(len(mi[0]))):
            if(mi[i0][i1] < 0):
                mo[i0][i1] = 0.1 * mi[i0][i1]
                # print("???: ", mi[i0][i1], mo[i0][i1])
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

mu = np.array([[8.22638e-7, -5.13539e-6, 7.16443e-16],
               [-6.99412e12, 3.21e10, -1.75e5],
               [7.27e5, -4.819e7, -7.4e-9]], dtype = float)
mv = np.array([[7.888e-31, -4.135e-25, 8.307e34],
               [-1.844e19, -3.08e-33, -6.71e7],
               [2.68e8, -1.038e34, -2.0679e-25]], dtype = float)
mw = np.array([[2.3058e18, -6.31e-30, -1.038e34],
               [-8.47e-22, -2.9e-11, -1.355e-20],
               [-3.9e-31, -3.125e-2, -2.646e-23]], dtype = float)
x0 = np.array([[-1.124],
               [1.73],
               [-1.327]], dtype = float)
x1 = np.array([[1.698],
               [1.414],
               [-5.91]], dtype = float)
x2 = np.array([[-2.09],
               [-3.35],
               [2.08]], dtype = float)
mh = np.array([[-4],
               [-2],
               [-2]], dtype = float)

ux0 = mu@x0
ux1 = mu@x1
ux2 = mu@x2

h1 = lk_relu(ux0 + mw@mh)
h2 = lk_relu(ux1 + mw@h1)
h3 = lk_relu(ux2 + mw@h2)
y0 = sigm(mv@h1)
y1 = sigm(mv@h2)
y2 = sigm(mv@h3)

print("ux0:\n", ux0)
print("ux1:\n", ux1)
print("ux2:\n", ux2)
print("h1:\n", h1)
print("h2:\n", h2)
print("h3:\n", h3)
# print("vh: ", mv@h1)
print("y0:\n", y0)
print("y1:\n", y1)
print("y2:\n", y2)