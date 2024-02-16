import random
import numpy as np
from bitstring import BitArray
# ==================================================
# @1000
# 21 4c // I_inst: load 010 0110 0001 00001 rs =  6, rt =  1, imm =   1
# @1002
# 4d 54 // I_inst: load 0101010001001101 rs = 10, rt =  2, imm =  13
# @1004
# 6e 42 // I_inst: load 0100001001101110 rs =  1, rt =  3, imm =  14
# ==================================================
# @1000
# e1 ff // -31
# @1002
# 1d 00 //  29
# @1004
# f2 ff // -14
# ==================================================

f_DRAM_inst = open('./DRAM/DRAM_inst.dat', 'w')
f_DRAM_data = open('./DRAM/DRAM_data.dat', 'w')
f_inst_func = open('./inst_func.txt', 'w')
kAddrMin = 0x1000
kAddrMax = 0x1fff
kDataMin = 0
kDataMax = 4096
kFunction = ['ADD', 'SUB', 'SetLessThan', 'Mult', 'Load', 'Load', 'Load', 'Store', 'Store', 'Store', 'BranchOnEqual']     # ['Jump']
kOffset = 0x1000
d0 = {}
# vr = []
# for i0 in range(16):
#     vr.append(BitArray(16))


# ( rs + immediate ) * 2 = 0x000 ~ 0xffe (12-bits)
# ( 0xffe - 0x000 ) / 2 = 4094 / 2 = 2047
# DRAM[ 0 ~ 2047 ]
# ( rs: 4-bits, 0~15 ) ( immediate: 5-bits, 0~31 )

def chko(n0: int):
    b0 = BitArray(32)
    b0.int32 = int(n0)
    b1 = b0[16:32]
    # if(n0 < 0):
    #     n1 = n0%(2**15) - 2**15
    # else:
    #     n1 = n0%(2**15)
    return b1.int16

def btod(b0: BitArray, b1: BitArray):
    # print("btod: ", b1.h, b0.h, (b1 + b0).h, (b1 + b0).int)
    return (b1 + b0).int

def dtob(d0: int):
    # print("check dtob: ", d0, int(d0), type(d0), type(int(d0)))
    b0 = BitArray(16)
    # print("check b0: ", b0)
    b0.int16 = int(d0)
    # print("check b0 2: ", b0)
    return b0[8:16], b0[0:8]

def rnda(vr: np.ndarray):
    L0 = []
    for i0 in range(16):
        if((vr[i0] + 15)*2 > -1 and (vr[i0] - 16)*2 < 0x0fff):
            L0.append(i0)
    if(len(L0) == 0):
        return -1, -1
    n0 = L0[random.randint(0, len(L0)-1)]
    n1 = random.randint(max(-16, 0 - vr[n0]), min(15, int(0x0ffe/2) - vr[n0]))
    # print(L0, len(L0), n0)
    return n0, n1

def tryr(id0: dict, id1: dict, ivr: np.ndarray, inow: int):
    d0 = id0.copy()
    d1 = id1.copy()
    vr = np.copy(ivr)
    pc = inow
    # inst = BitArray()
    while(True):
        # print("pc: ", pc, "check: \n", d1)
        # print(type(d1))
        # print(type(pc))
        op = ((d1[pc])[0:3]).b
        fu = d1[pc][15:16].b
        ns = d1[pc][3:7].uint4
        nt = d1[pc][7:11].uint4
        nd = d1[pc][11:15].uint4
        ni = d1[pc][11:16].int5
        # print("check vrnt: ", vr[nt], op)
        if(op == "000" and fu == '1'):
            vr[nd] = chko(vr[ns] + vr[nt])
            nex = pc + 2
        elif(op == "000" and fu == '0'):
            vr[nd] = chko(vr[ns] - vr[nt])
            nex = pc + 2
        elif(op == "001" and fu == '1'):
            if(vr[ns] < vr[nt]):
                vr[nd] = 1
            else:
                vr[nd] = 0
            nex = pc + 2
        elif(op == "001" and fu == '0'):
            vr[nd] = chko(vr[ns] * vr[nt])
            nex = pc + 2
        elif(op == "011"):
            vr[nt] = btod(d0[(vr[ns] + ni)*2 + 0x1000], d0[(vr[ns] + ni)*2 + 0x1000 + 1])
            nex = pc + 2
        elif(op == "010"):
            d0[(vr[ns] + ni)*2 + 0x1000], d0[(vr[ns] + ni)*2 + 0x1000 + 1] = dtob(vr[nt])
            nex = pc + 2
        elif(op == "101"):
            if(vr[ns] == vr[nt]):
                nex = pc + 2 + ni*2
            else:
                nex = pc + 2
        elif(op == "100"):
            nex = (BitArray(bin = "000") + d1[pc][3:16]).int16
        else:
            nex = pc + 2
        
        if(nex > inow):
            return False, d0, vr, nex
        elif(pc == inow):
            return True, d0, vr, nex
        else:
            pc = nex

def GenerateDRAM_inst(d0: dict):
    rt_int = -1
    d1 = {}
    vr = np.zeros(16, dtype = int)
    func = "Load"
    # 'store' values to core_r0 ~ core_r15
    for i in range(kAddrMin, kAddrMin + 32, 2):
        f_DRAM_inst.write('@' + format(i, 'x') + '\n')
        rt_int = rt_int + 1
        ns, ni = rnda(vr)
        bs = BitArray(4)
        bi = BitArray(5)
        bs.uint4 = ns
        bi.int5 = ni
        rt = '{:0>4b}'.format( rt_int, 'x')
        rs = bs.b4
        immediate = bi.b5
        inst = '011' + rs + rt + immediate
        b = BitArray(bin=inst)
        temp = '{:0>4x}'.format(b.uint, 'x')
        
        # print(0 - vr[ns], int(0x0ffe/2) - vr[ns], ni, "{:0>5x}".format((vr[ns] + ni)*2 + 0x1000))
        vr[rt_int] = btod(d0[(vr[bs.uint4] + bi.int5)*2 + 0x1000], d0[(vr[bs.uint4] + bi.int5)*2 + 0x1000 + 1])
        d1.update({i:b})
        f_DRAM_inst.write( temp[2] + temp[3] + ' ' + temp[0] + temp[1] + '\n')
        f_inst_func.write('@' + format(i, 'x') + ' : ' + 'Load' + '\n')
        f_inst_func.write("check: {} {} {} {}\n".format(func, ns, rt_int, ni))
        f_inst_func.write("vr:\nr0:\t{0}\tr1:\t{1}\tr2:\t{2}\tr3:\t{3}\n".format(vr[0],  vr[1],  vr[2],  vr[3]))
        f_inst_func.write("r4:\t{0}\tr5:\t{1}\tr6:\t{2}\tr7:\t{3}\n".format(vr[4],  vr[5],  vr[6],  vr[7]))
        f_inst_func.write("r8:\t{0}\tr9:\t{1}\tr10:\t{2}\tr11:\t{3}\n".format(vr[8],  vr[9],  vr[10], vr[11]))
        f_inst_func.write("r12:\t{0}\tr13:\t{1}\tr14:\t{2}\tr15:\t{3}\n".format(vr[12], vr[13], vr[14], vr[15]))

    nex = kAddrMin+32
    for i in range(kAddrMin+32, kAddrMax, 2):
        f_DRAM_inst.write('@' + format(i, 'x') + '\n')
        if(i == 0x1ffe):
            func = random.choice(kFunction)
        else:
            func = random.choice(kFunction+['Jump'])
        if(func == "Load" or "Store"):
            ns, ni = rnda(vr)
            if(ns == -1 and ni == -1):
                func = "SetLessThan"
                ns = random.randint(0, 15)
                ni = random.randint(-16, 15)
        else:
            ns = random.randint(0, 15)
            ni = random.randint(-16, 15)
        nt = random.randint(0, 15)
        nd = random.randint(0, 15)
        
        bi.int5 = ni
        rs = '{:0>4b}'.format(ns, 'x')
        rt = '{:0>4b}'.format(nt, 'x')
        rd = '{:0>4b}'.format(nd, 'x')
        immediate = bi.b5
        
        if func == 'ADD':
            inst = '000' + rs + rt + rd + '1'
            if(i >= nex):
                vr[nd] = chko(vr[ns] + vr[nt])
        elif func == 'SUB':
            inst = '000' + rs + rt + rd + '0'
            if(i >= nex):
                vr[nd] = chko(vr[ns] - vr[nt])
        elif func == 'SetLessThan':
            inst = '001' + rs + rt + rd + '1'
            if(i >= nex):
                if(vr[ns] < vr[nt]):
                    vr[nd] = 1
                else:
                    vr[nd] = 0
        elif func == 'Mult':
            inst = '001' + rs + rt + rd + '0'
            if(i >= nex):
                vr[nd] = chko(vr[ns] * vr[nt])
        elif func == 'Load':    # TODO: does not deal with data dependence
            inst = '011' + rs + rt + immediate
            if(i >= nex):
                vr[nt] = btod(d0[(vr[ns] + ni)*2 + 0x1000], d0[(vr[ns] + ni)*2 + 0x1000 + 1])
        elif func == 'Store':   # TODO: does not deal with data dependence
            inst = '010' + rs + rt + immediate
            # print("check vrnt: ", vr[nt])
            if(i >= nex):
                d0[(vr[ns] + ni)*2 + 0x1000], d0[(vr[ns] + ni)*2 + 0x1000 + 1] = dtob(vr[nt])
        elif func == 'BranchOnEqual':
            # immediate = random.randint(0, 15)    # only positive values
            # immediate = random.randint(0, 31)
            # if immediate%2==1:
            #     immediate = immediate - 1
            # immediate = '{:0>5b}'.format(ni, 'x')
            inst = '101' + rs + rt + immediate
            if(i >= nex):
                d1.update({i: BitArray(bin = inst)})
                ok0, od0, ovr, nex = tryr(d0, d1, vr, i)
                if(ok0):
                    ni = random.randint(0, 15)
                    bi.int5 = ni
                    immediate = bi.b5
                    inst = '101' + rs + rt + immediate
                    if(vr[ns] == vr[nt]):
                        nex = i + 2 + ni*2
                else:
                    d0 = od0.copy()
                    vr = np.copy(ovr)
        elif func == 'Jump':
            # jump_flag = True
            #
            a = max(kAddrMin, i - 64 + 2 - 64)
            b = min(kAddrMax, i + 64 + 64)
            addr_int = random.randint(a, b)
            # print(format(i, 'x')+' a = '+str(a)+' b = '+str(b)+' from ' + str(i) + ' to ' + str(addr_int))
            if addr_int%2 == 1:
                addr_int = addr_int - 1
            addr = '{:0>13b}'.format(addr_int, 'x')
            inst = '100' + addr
            if(i >= nex):
                d1.update({i: BitArray(bin = inst)})
                ok0, od0, ovr, nex = tryr(d0, d1, vr, i)
                if(ok0):
                    addr_int = random.randint(i+2, b)
                    if addr_int%2 == 1:
                        addr_int = addr_int - 1
                    addr = '{:0>13b}'.format(addr_int, 'x')
                    inst = '100' + addr
                    nex = BitArray(bin = "000" + addr).int16
                else:
                    d0 = od0.copy()
                    vr = np.copy(ovr)
        b = BitArray(bin=inst)
        temp = '{:0>4x}'.format(b.uint, 'x')
        # f_DRAM_inst.write( func + ' : ' + inst + '\n')
        d1.update({i:b})
        f_DRAM_inst.write(temp[2] + temp[3] + ' ' + temp[0] + temp[1] + '\n')
        f_inst_func.write('@' + format(i, 'x') + ' : ' + func + '\n')
        f_inst_func.write("check: func:{} rs:{} rt:{} rd:{} immed:{} addr:{} pc:{:0>4x}, next:{:0>4x}\n".format(func, ns, nt, nd, ni, (BitArray(bin = "000") + b[3:16]).h16, i, nex))
        f_inst_func.write("vr:\nr0:\t{0}\tr1:\t{1}\tr2:\t{2}\tr3:\t{3}\n".format(vr[0],  vr[1],  vr[2],  vr[3]))
        f_inst_func.write("r4:\t{0}\tr5:\t{1}\tr6:\t{2}\tr7:\t{3}\n".format(vr[4],  vr[5],  vr[6],  vr[7]))
        f_inst_func.write("r8:\t{0}\tr9:\t{1}\tr10:\t{2}\tr11:\t{3}\n".format(vr[8],  vr[9],  vr[10], vr[11]))
        f_inst_func.write("r12:\t{0}\tr13:\t{1}\tr14:\t{2}\tr15:\t{3}\n".format(vr[12], vr[13], vr[14], vr[15]))
        # f_inst_func.write("vr:\nr0:\t{0}\tr1:\t{1}\tr2:\t{2}\tr3:\t{3}".format(vr[0],  vr[1],  vr[2],  vr[3]),
        #                   "\nr4:\t{0}\tr5:\t{1}\tr6:\t{2}\tr7:\t{3}".format(vr[4],  vr[5],  vr[6],  vr[7]),
        #                   "\nr8:\t{0}\tr9:\t{1}\tr10:\t{2}\tr11:\t{3}".format(vr[8],  vr[9],  vr[10], vr[11]),
        #                   "\nr12:\t{0}\tr13:\t{1}\tr14:\t{2}\tr15:\t{3}".format(vr[12], vr[13], vr[14], vr[15]))
    #
    # f_DRAM_inst.write('@' + format(0x1ffe, 'x') + '\n')
    # addr_int = random.randint(kAddrMin, kAddrMin + 256)
    # if addr_int % 2 == 1:
    #     addr_int = addr_int - 1
    # addr = '{:0>13b}'.format(addr_int, 'x')
    # inst = '100' + addr
    # b = BitArray(bin=inst)
    # temp = '{:0>4x}'.format(b.uint, 'x')
    # f_DRAM_inst.write(temp[2] + temp[3] + ' ' + temp[0] + temp[1] + '\n')
    # f_inst_func.write('@' + format(0x1ffe, 'x') + ' : ' + func + '\n')

def GenerateDRAM_data():
    j = 0
    b0 = BitArray(16)
    d0 = {}
    for i in range(kAddrMin, kAddrMax, 2):
        f_DRAM_data.write('@' + format(i, 'x') + '\n')
        j = j + 1
        n0 = random.randint(kDataMin, kDataMax)
        b0.uint16 = n0
        # temp = '{:0>4x}'.format( random.randint(kDataMin, kDataMax), 'x')
        d0.update({i:b0[8:16], i+1:b0[0:8]})
        f_DRAM_data.write( b0[8:16].h + ' ' + b0[0:8].h + '\n')
        # f_DRAM_data.write( temp[2] + temp[3] + ' ' + temp[0] + temp[1] + '\n')
    return d0

if __name__ == '__main__':
    nseed = input("input random seed: ")
    random.seed(nseed)
    d0 = GenerateDRAM_data()
    # print(d0)
    GenerateDRAM_inst(d0)

f_DRAM_inst.close()
f_DRAM_data.close()
f_inst_func.close()