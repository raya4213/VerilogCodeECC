import binascii
from datetime import datetime
import gmpy2
import random
import array
import copy
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, ReadOnly
from cocotb.result import TestFailure, ReturnValue
from cocotb.binary import BinaryValue
import numpy as np
np.set_printoptions(formatter={'int':lambda x:hex(int(x))})

import binascii
import numpy as np
import gmpy2
import random
import array
import copy
import hashlib
#import gmpy

np.set_printoptions(formatter={'int':hex})


class Binfield:
    def __init__(self, Polynomial):        
        Polynomial =  self.str2nparray(Polynomial)
        self.Polynomial = Polynomial
        #print self.Polynomial
        self.make_mul_lut()
        self.make_sqr_lut()
        self.gen_mod_table()
        
    def str2nparray(self, A):
        A = '0'*(8 - len(A)%8) + A
        A = binascii.unhexlify(A)
        A = np.fromstring(A[::-1], dtype='uint32') 
        return A

    def nparray2str(self, A):
        c = ''
        d = A.view('uint8')
        for i in d[::-1]:
           
            c+=binascii.hexlify(i)
        return c 
    
    def nparray2str2(self, A):
        c = ''
        d = A.view('uint8')
        for i in d:
    
            c+=binascii.hexlify(i)
        return c  
        
    def mul_2 (self,a, b):
        a1 = (a&2)>>1
        a0 = (a&1)
        b1 = (b&2)>>1
        b0 = (b&1)

        d2 = (a1 & b1)&1
        d0 = (a0 & b0)&1
        d1 = (((a1 ^ a0) & (b1 ^ b0)) ^ d0 ^ d2 )&1
        return d2<<2 ^ d1 <<1 ^ d0
    
    def mul_2 (self,a, b):
        a1 = (a&2)>>1
        a0 = (a&1)
        b1 = (b&2)>>1
        b0 = (b&1)

        d2 = (a1 & b1)&1
        d0 = (a0 & b0)&1
        d1 = (((a1 ^ a0) & (b1 ^ b0)) ^ d0 ^ d2 )&1
        return d2<<2 ^ d1 <<1 ^ d0
 
    
    def mul_4 (self,a, b):
        a1 = (a&0xC)>>2
        a0 = (a&0x3)
        b1 = (b&0xc)>>2
        b0 = (b&0x3)

        d2 = self.mul_2(a1, b1)
        d0 = self.mul_2(a0, b0)
        d1 = self.mul_2((a1 ^ a0), (b1 ^ b0)) ^ d0 ^ d2
        
        return d2<<4 ^ d1 <<2 ^ d0
    
    def make_mul_lut(self):
        MUL_LUT = []
        for i in range(0,256):
            b = self.mul_4((i&0xf0)>>4,i&0x0f)
            MUL_LUT.append(b)
        self.MUL_LUT = np.array(MUL_LUT)
        return 0
        
    def mul_8 (self,a, b):
        a1 = (a&0xf0)>>4
        a0 = (a&0xf)
        b1 = (b&0xf0)>>4
        b0 = (b&0xf)

        d2 = self.mul_4(a1, b1)
        d0 = self.mul_4(a0, b0)
        d1 = self.mul_4((a1 ^ a0), (b1 ^ b0)) ^ d0 ^ d2
 
        return d2<<8 ^ d1 <<4 ^ d0
    
    
    def mul_8_lut (self,a, b):
        a1 = (a&0xf0)>>4
        a0 = (a&0xf)
        b1 = (b&0xf0)>>4
        b0 = (b&0xf)

        d2 = self.MUL_LUT[a1<<4 | b1]
        d0 = self.MUL_LUT[a0<<4 | b0]
        d1 = self.MUL_LUT[(a1 ^ a0)<<4 | (b1 ^ b0)] ^ d0 ^ d2
        return int(d2<<8 ^ d1 <<4 ^ d0)
    
    def mul_32 (self, a, b):
        a3 = (a&0xff000000)>>24
        a2 = (a&0xff0000)>>16
        a1 = (a&0xff00)>>8
        a0 = (a&0xff)
        b3 = (b&0xff000000)>>24
        b2 = (b&0xff0000)>>16
        b1 = (b&0xff00)>>8
        b0 = (b&0xff)
        
        d3 = self.mul_8_lut(a3, b3)
        d2 = self.mul_8_lut(a2, b2)
        d1 = self.mul_8_lut(a1, b1)
        d0 = self.mul_8_lut(a0, b0)
        
        f1 = d3 ^ d2
        f0 = d1 ^ d0
        f  = f1 ^ f0
        
        c6 = d3
        c5 = self.mul_8_lut(a3 ^ a2, b3 ^ b2) ^ f1
        c4 = self.mul_8_lut(a3 ^ a1, b3 ^ b1) ^ f1 ^ d1
        c2 = self.mul_8_lut(a2 ^ a0, b2 ^ b0) ^ f0 ^ d2
        c1 = self.mul_8_lut(a1 ^ a0, b1 ^ b0) ^ f0
        c0 = d0        
        c3 = self.mul_8_lut(a3 ^ a2 ^ a1 ^ a0 , b3 ^ b2 ^ b1 ^  b0) ^ c1 ^ c2 ^ c0 ^ c4 ^ c5 ^ c6
        r = np.array([(c3&0xFF)<<24 ^ c2<<16 ^ c1<<8 ^ c0 , c6<<16 ^ c5<<8 ^ c4 ^ (c3&0xFF00) >>8])
      
        return r 
    
        
    def mul_64 (self, a, b):
        a1 = a[1]
        a0 = a[0]
        b1 = b[1]
        b0 = b[0]

        d2 = self.mul_32(a1, b1)
        d0 = self.mul_32(a0, b0)
        d1 = (self.mul_32((a1^a0), (b1^b0)) ^ d0 ^ d2)
                
        r = np.array([d0[0], d0[1] ^ d1[0], d1[1] ^ d2[0], d2[1]])
        return r
    
  
    
    def make_sqr_lut(self):
        LUT = np.array([0x00, 0x01, 0x4, 0x05, 0x10, 0x11, 0x14, 
                        0x15, 0x40, 0x41, 0x44, 0x45, 0x50, 0x51, 0x54, 0x55])
        a = np.arange(256)
        b = [ LUT[a & 0x0F], LUT[(a & 0xF0)>> 4]]
        c = []
        for i in range(0,256):
            a = (b[1][i] << 8) | b[0][i] 
            c.append(a)
        self.LUT8 = np.array(c, dtype='uint16')        
        
        
    def square (self, A):
      
        b = A.view('uint8')
        c = self.LUT8[b]
        d = c.view('uint32')
        while (d[-1] == 0):
            if (len(d) == 1):
                break
            d = d[:-1]   
        return d
    
    def bin_sqr (self, A):
        A = self.str2nparray(A)
  
        return self.square(A)
    
    def bin_mul_64 (self, A, B):
        A = binascii.unhexlify(A)
        A = np.fromstring(A, dtype='uint32') 
        print A
        B = binascii.unhexlify(B)
        B = np.fromstring(B, dtype='uint32') 
        print B
        return self.mul_64(A, B)
    
            
    
    def gen_mod_table(self):
        index = 0
        p = self.Polynomial.view('uint8')
        p = p[::-1]
        while (p[0] == 0):
            if (len(p) == 1):
                break
            p = p[1:]
            
        f_bit_pos = gmpy2.bit_length(int(p[0])) 
        
        self.Polly_byte_len = len(p)
        self.Polly_bit_len = f_bit_pos
    
      
        p = np.array(p)
      
        
        p1 = p >> (f_bit_pos-1)
        p2 = p << (9 - f_bit_pos)
       

        p1 = np.append(p1, 0)
        p2 = np.append(0, p2)   
        pr = p1 ^ p2 & 0xff


        p1 = pr >> 1
        p2 = pr << 7
      
        p1 = np.append(p1, 0)
        p2 = np.append(0, p2)        
        pl = (p1 ^ p2) & 0xff
        pl = pl[1:]
        
        pl[0] = pl[0] & 0x7F
        self.pr = pr
        poly_7 = []
        p3 = np.append(0, pr[1:])
        poly_7.append(p3)
        
                
        for i in range(7):
            p1 = p3 << (1)
            p2 = p3 >> (7)
            p2 = np.append(p2[1:], 0)
            p3 = (p1 ^ p2) & 0xff
       
            if not p3[0] == 0:
                p3 = p3 ^ pr
            poly_7.append(p3)            
        
  
        index = []
        
        for i in range(len(poly_7[0])):
            for j in poly_7:
                if j[i] != 0:
                    index.append(i)
                    break  
       
            
        Polly_table = []
        for i in range(256):
            val = np.zeros(len(poly_7[0]),  dtype='uint8')
            for j in range(8):
                if ((i >> j) & 0x1):
                    val = val ^ poly_7[j]
            indexed_val = []
            for k in index:
                indexed_val.append(val[k])                
            Polly_table.append(np.array(indexed_val))
      
        self.Polly_table = Polly_table
        self.Polly_index = index
        return 0
 
    
    def bin_mod (self, A):
        A =  self.str2nparray(A)
        return self.modulus(A)
            
    def bin_mul(self, A, B):

        A =  self.str2nparray(A)
        B =  self.str2nparray(B)
        return self.multiplication(A ,B)      
        
    def multiplication(self, A, B):

        l1 = len(A)
        l2 = len(B)
        l = max(l1, l2)
        size = 1
        l3 = l
        while l3 != 1:
            l3 = l3/2
            size *=2
        if l > size:
            size *=2
        A = np.append(A, np.zeros(size-l1, dtype=np.int32))
        B = np.append(B, np.zeros(size-l2, dtype=np.int32))
        C =self.mul_recr(A ,B)
        while(C[-1]==0):
            if len(C) == 1:
                break
            C = C[:-1]
        
        C = np.array(C, dtype='uint32')
       #print (C)
        return C
    
    def mul_recr(self,A, B):   
        l = len(A)        
        if(l==1):
            if A[0] == 0 | B[0] == 0:
                d = np.array([0, 0], dtype="uint32")
            
                return d
            else:
                d = self.mul_32(A , B)
            
                return d
        else:
            d0 = self.mul_recr(A[0:l/2],B[0:l/2])
            d2 = self.mul_recr(A[l/2:l],B[l/2:l])
            d1 = self.mul_recr((A[l/2:l] ^ A[0:l/2]), (B[l/2:l] ^ B[0:(l/2)])) ^ d0 ^ d2
            
            l = len(d1)/2
       
            
            d0 = np.append(d0, np.zeros(2*l, dtype=np.int32))
            d1 = np.append(np.zeros(l, dtype=np.int32), d1)
            d1 = np.append(d1, np.zeros(l, dtype=np.int32))
            d2 = np.append(np.zeros(2*l, dtype=np.int32), d2)
        
            d2 = d2^d1^d0
            return d2
    
    
    
    
    def remove_0(self, A):
        while A[0] == 0:
            if len(A) == 1:
                break
            A = A[1:]
        return A

    
    def modulus1 (self, A):
        B = np.copy(A)
        p1 = B.view('uint8')        
        p = p1[::-1]
        
        byte_len = self.Polly_byte_len
        bit_len = self.Polly_bit_len 
  
        while p[0] == 0:
            if len(p) == 1:
                break
            p = p[1:]
       
        '''Reduction based on lookup tables'''
        
        while len(p) > byte_len:
            red_poly = self.Polly_table[p[0]]
   
            for j,k in zip(red_poly, self.Polly_index):
                if j != 0:
                    p[k] ^= j            
            p = p[1:]
         
            while p[0] == 0:
                if len(p) == 1:
                    break
                p = p[1:]
     
            
                
        print p
            
        while p[0] == 0:
            if len(p) == 1:
                break
            p = p[1:]
    
        if (len(p)+1 < self.Polly_index[-1]):
            return p
        
        r = p[0] & (gmpy2.bit_mask(bit_len-1) ^ 0xFF)

        if r != 0:
           
            '''Last byte reduction when polynomial is equal to primitive'''
            if (len(p) == self.Polly_index[-1]):     
                red_poly = self.Polly_table[r]
            
                for j,k in zip(red_poly, self.Polly_index):
                    if (k < len(p)):
                        p[k] ^= j
                p[-1] ^= r
            else:
                '''Reduction by hand'''
                while r != 0:
                    f_bit_pos = gmpy2.bit_length(r)
                    p1 = self.pr << (f_bit_pos -1)
                    p2 = self.pr >> (9 - f_bit_pos)
                    p1 = p1[:-1]
                    p2 = p2[1:]
                    p = p ^ p1 ^ p2
                    r = p[-1] & (gmpy2.bit_mask(bit_len-1) ^ 0xFF)
                
        while p[0] == 0:
            if len(p) == 1:
                break
            p = p[1:]
 
        
        p = p[::-1]
      
        q = np.append(np.zeros(4 - len(p)%4, dtype=np.int8), p)
        q = np.array(q, dtype='uint8')
      
        q = np.getbuffer(q)
        q = np.frombuffer(q, dtype='uint32')        

        return  q     

    
    def modulus (self, A):
        
        B = np.copy(A)
        p1 = B.view('uint8')       
        p = p1[::-1]
        p = self.remove_0(p)
        Pl = self.Polynomial.view('uint8')
        Polynomial = Pl[::-1]
        Polynomial = self.remove_0(Polynomial)
        pf_bit_pos = gmpy2.bit_length(int(Polynomial[0]))
       
        p1 = ( Polynomial >> (pf_bit_pos-1) ) & 0xff
        p2 = ( Polynomial << (9 - pf_bit_pos) ) & 0xff
        p1 = np.append(p1, 0)
        p2 = np.append(0, p2)
        pr = p1 ^ p2 & 0xff
      
        while len(p) >= len(Polynomial):
            #print p
            if len(p) > len(Polynomial):
                red_poly = self.Polly_table[p[0]]
                for j,k in zip(red_poly, self.Polly_index):
                    if j != 0:
                        p[k] ^= j           
                p = p[1:]
                while p[0] == 0:
                    if len(p) == 1:
                        break
                    p = p[1:]
            else:               
                f_bit_pos = gmpy2.bit_length(int(p[0]))
                if f_bit_pos < pf_bit_pos:
                    break               

                p1 = pr << (f_bit_pos -1) & 0xff
                p2 = pr >> (9 - f_bit_pos) & 0xff          
                p1 = np.append(0, p1)
                p2 = np.append(p2, 0)
                pp = p1 ^ p2
                pp = pp[1:]
                if pp[-1] == 0:
                    pp = pp[:-1]
                pp = p[:len(pp)] ^ pp
                p = np.append(pp, p[len(pp):])
                p = self.remove_0(p)
                     
           
        p = p[::-1]
        q = np.append( p,np.zeros(4 - len(p)%4, dtype=np.int8))
        q = np.array(q, dtype='uint8')
        q = np.getbuffer(q)
        q = np.frombuffer(q, dtype='uint32')
              

        return  q     
    
    
    
    def bin_inverse(self,A):
        p=self.Polynomial.tolist()
                 
        while p[-1] == 0:
            if len(p) == 1:
                break
            p = p[:-1]
        length=len(p)*32-32+gmpy2.bit_length(p[-1])-1
        A=self.str2nparray(A)
     
        array=self.baumer_chain(length)
  
        C=self.inverse1(A)
        
        return C
    
    
    
    def inverse1(self,A):
        P=self.remove_1(self.Polynomial)
        l=((len(P)-1)*32)+gmpy2.bit_length(int(P[-1]))-1
    
        array = self.baumer_chain(l)
        count=0
        inv_array=np.array([A],dtype='uint32')
        prev=np.copy(A)
        #print array
        for i in range(0,len(array)-1,2):
            #print i
            x=array[i]
            y=array[i+1]
            var=y           #how many time squaring
            #print var,x,y
            n=prev
            while(var!=0):
               
                var=var-1
                sqr=self.modulus(self.square(n))
                n=sqr
                #break
            
        
            
            if(y==1):
                f=A
            else:
                f=prev
            #print f,d
            mul=self.modulus(self.multiplication(f,sqr))
            count+=1
            prev=mul
            
            
        final=self.modulus(self.square(prev))
        #print "number of multiplication",count   
            
                
            
            
        #print prev   
            #print x,y
        return final
    
    def baumer_chain(self,length):
        
        n=length
        #print "len",n
        a=np.array([],dtype=int)
        n=(n-1)
        while(n):
            if(n%2==0):
                a=np.append(n,a)
                n=n/2
            else:
                a=np.append(n,a)
                n=n-1

        #print a
        array=np.array([],dtype=int)
        for i in a:
            if(i>1):
                if(i%2==0):
                    array=np.append(array,(i/2,i/2))
                else:
                    array=np.append(array,(i-1,1))
        return array  
    
    def bin_point_double(self,x_cor,y_cor,order,a):
        
     
        x_cor =  self.str2nparray(x_cor)
        y_cor =  self.str2nparray(y_cor)
        a =  self.str2nparray(a)
        return self.point_doubl(x_cor,y_cor,a)
    
    def bin_point_add(self,x1,y1,x2,y2,a):
        x1 =  self.str2nparray(x1)
        y1 =  self.str2nparray(y1)
        x2 =  self.str2nparray(x2)
        y2 =  self.str2nparray(y2)
        a =  self.str2nparray(a)
        return self.point_add(x1,y1,x2,y2,a)
    
    
    
    def bin_public_key_gen(self,x,y,a,n):
        x=self.str2nparray(x)
        y=self.str2nparray(y)
        a=self.str2nparray(a)
        return self.public_key_gen(x,y,a,n)
        
    def public_key_gen(self,x,y,a,n):
     
        sq=[]
        sq_x=[]
    
        public_key=[]
        bit_len = gmpy2.bit_length(n)
        
        ####public key generation  #########3
        
        if(n&0x1):
              sq_x.append(x)
              sq_x.append(y)
            
        for i in range(1,bit_len):
            if((n>>i)&0x01):
              
                sq=self.point_doubl(x,y,a)
                sq_x.append(sq[0])
                sq_x.append(sq[1])
                x=sq[0]
                y=sq[1]
            else:
                sq=self.point_doubl(x,y,a)
                x=sq[0]
                y=sq[1]
                    
       
        j=0  
        sq=[]
        
        if(len(sq_x)==2):
            return sq_x[-2:]
        x2=sq_x[2]
        y2=sq_x[3]
        for i in range(len(sq_x)/2-1):
          
            sq = self.point_add(sq_x[j],sq_x[j+1],x2,y2,a)
            public_key.append(sq[0])
            public_key.append(sq[1])
            if(i==0):
                j=j+4
            else:
                j=j+2
            x2=(sq[0])
            y2=(sq[1])  
    
        return public_key[-2:]
    
    
    
    
    
    def point_doubl(self,x1,y1,a):
        
        x1=np.append(x1,np.zeros(len(self.Polynomial)-len(x1),dtype='uint32'))
        y1=np.append(y1,np.zeros(len(self.Polynomial)-len(y1),dtype='uint32'))
        a=np.append(a,np.zeros(len(self.Polynomial)-len(a),dtype='uint32'))
        sq=[]

        den = self.inverse1(x1)
     
        
        den=np.append(den,np.zeros(len(self.Polynomial)-len(den),dtype='uint32'))
        parameter_2 = self.modulus(self.multiplication(y1,den))
        parameter_2=np.append(parameter_2,np.zeros(len(self.Polynomial)-len(parameter_2),dtype='uint32'))
        
        lamda = x1 ^ parameter_2  
   
        lamda_sqr=self.modulus(self.square(lamda))
        lamda_sqr=np.append(lamda_sqr,np.zeros(len(self.Polynomial)-len(lamda_sqr),dtype='uint32'))
        x2 = lamda_sqr^lamda^a
  
        var1=self.modulus(self.square(x1))
        var2=self.modulus(self.multiplication(lamda,x2))
        var1=np.append(var1,np.zeros(len(self.Polynomial)-len(var1),dtype='uint32'))
        var2=np.append(var2,np.zeros(len(self.Polynomial)-len(var2),dtype='uint32'))
        y2 = var1^var2^x2
        
        x1=x2
        y1=y2
        sq.append(x1)
        sq.append(y1)

        return  sq
    
  
    
    def point_add(self,x1,y1,x2,y2,a):
        x1=np.append(x1,np.zeros(len(self.Polynomial)-len(x1),dtype='uint32'))
        y1=np.append(y1,np.zeros(len(self.Polynomial)-len(y1),dtype='uint32'))
        x2=np.append(x2,np.zeros(len(self.Polynomial)-len(x2),dtype='uint32'))
        y2=np.append(y2,np.zeros(len(self.Polynomial)-len(y2),dtype='uint32'))
        a=np.append(a,np.zeros(len(self.Polynomial)-len(a),dtype='uint32'))
        sq = []
        #print len(x1),len(x2)
        den = self.inverse1(x1^x2)
        
        lamda = self.modulus(self.multiplication(y1^y2,den))
        
        lamda=np.append(lamda,np.zeros(len(self.Polynomial)-len(lamda),dtype='uint32'))
        
        var1=self.modulus(self.square(lamda))
        var1=np.append(var1,np.zeros(len(self.Polynomial)-len(var1),dtype='uint32'))
        
        x3 = var1^lamda^x1^x2^a
        
        var2=self.modulus(self.multiplication(lamda,(x1^x3)))
        var2=np.append(var2,np.zeros(len(self.Polynomial)-len(var2),dtype='uint32'))
        
        y3 = var2^x3^y1
        sq.append(x3)
        sq.append(y3)
     
        return sq
        
    
    def digitial_generation(self,message,Curve_Polynomial,X,Y,Order,A,d_A):
        r=np.array([0x0],dtype='uint32')
        m=hashlib.sha256(message).hexdigest()
        
        Order_np = self.str2nparray(Order) 
        Order_int = int(Order,16)
        
        l=(len(Order_np)-1)*32+gmpy2.bit_length(int(Order_np[-1]))
     
        m = field.str2nparray(m)
        size = l/32+1
        m=self.remove_1(m)
   
        if(l>=256):
            rem=l-256
            chunk_added=(rem/32)+1
            m=np.append(np.zeros(chunk_added,dtype='uint32'),m)
            part=32-(l+chunk_added)%32
        else:
            m = m[len(m)-size:]
            part = 32-l%32

        X1=m>>part
        Y1=m<<(32-part)
        Z=np.bitwise_xor(Y1[1:],X1[:-1])
        Z=np.append(Z,X1[-1])
        
        Z = self.nparray2str(Z)
        Z = int(Z,16)
        
        Z = gmpy2.f_mod(Z,Order_int)
        S=0
        
        while(S==0):
            while(np.all(r[0]==0)):
                k=random.randint(1,Order_int-1)
                r=self.bin_public_key_gen(X,Y,A,k)

            k_inv=gmpy2.invert(k,Order_int)

            r = self.nparray2str(r[0])
            r = int(r,16)
            r=gmpy2.f_mod(r,Order_int)
            rd_A = gmpy2.mul(r,d_A)
            rd_A = gmpy2.f_mod(rd_A,Order_int)


            Zrd_A = rd_A + Z

            Zrd_A = int(Zrd_A)
            k_inv = int(k_inv)

            S = gmpy2.mul(Zrd_A,k_inv)
            S = gmpy2.f_mod(S,Order_int)

        
 
        
        return r,S
    
    
    def equal_nparray(self,A,B):
        if(len(A)>len(B)):
            B=np.append(B,np.zeros(len(A)-len(B),dtype='uint32'))
        else:
            A=np.append(A,np.zeros(len(B)-len(A),dtype='uint32'))
        return A,B
    
    
    
    def digitial_Verification(self,message,Order,X,Y,A,d_A,r,S):
        
        
        X=self.str2nparray(X)
        Y=self.str2nparray(Y)

        A=self.str2nparray(A)
        
        m=hashlib.sha256(message).hexdigest()
      
        Order_np = self.str2nparray(Order) 
        Order_int = int(Order,16)
        
        l=(len(Order_np)-1)*32+gmpy2.bit_length(int(Order_np[-1]))
      
        m = field.str2nparray(m)
        size = l/32+1
        m=self.remove_1(m)
 
        if(l>=256):
            rem=l-256
            chunk_added=(rem/32)+1
            m=np.append(np.zeros(chunk_added,dtype='uint32'),m)
            part=32-(l+chunk_added)%32
        else:
            m = m[len(m)-size:]
            part = 32-l%32

        X1=m>>part
        Y1=m<<(32-part)
        Z=np.bitwise_xor(Y1[1:],X1[:-1])
        Z=np.append(Z,X1[-1])
        
        Z = self.nparray2str(Z)
        Z = int(Z,16)
        Z = gmpy2.f_mod(Z,Order_int)                               #####Truncated Message
        
        w=gmpy2.invert(S,Order_int) 
        
        u1 = gmpy2.mul(Z,w)
        u1 = gmpy2.f_mod(u1,Order_int)
       
        u2 = gmpy2.mul(r,w)
        u2 = gmpy2.f_mod(u2,Order_int)
      
        Q_A=self.public_key_gen(X,Y,A,d_A)   #Q_A = d_A * G    
 
       
        X1=self.public_key_gen(X,Y,A,int(u1))
        X2=self.public_key_gen(Q_A[0],Q_A[1],A,int(u2))    #u2*Q_A
        X3=self.point_add(X1[0],X1[1],X2[0],X2[1],A)
        X3=self.nparray2str(X3[0])
        X3 = gmpy2.f_mod(int(X3,16),Order_int)
        
        #print X3[0]
        
        return X3
    
    def remove_1(self, A):
        while A[-1] == 0:
            if len(A) == 1:
                break
            A = A[:-1]
        return A
        
        
        

class Scalar_mul(object):

    def __init__(self, dut):
        self.dut=dut

    def str2nparray(self, A):
        A = '0'*(8 - len(A)%8) + A
        A = binascii.unhexlify(A)
        A = np.fromstring(A[::-1], dtype='uint32') 
        return A
    
    def nparray2str2(self, A):
        c = ''
        d = A.view('uint8')
        for i in d:
            c+=binascii.hexlify(i)
        return c 
    
    
    def remove_1(self, A):
        while A[-1] == 0:
            if len(A) == 1:
                break
            A = A[:-1]
        return A
    
    def remove_0(self, A):
        while A[0] == 0:
            if len(A) == 1:
                break
            A = A[1:]
        return A
     
    
    def Curve_Calculation(self,Polynomial):    
        Curve_Polynomial=np.array([],dtype='uint8')    
        Polynomial=self.str2nparray(Polynomial)
        Curve_len=(len(Polynomial)-1)*32+gmpy2.bit_length(int(Polynomial[-1]))-1
        D=Polynomial.view('uint8')[::-1]
        D=self.remove_0(D)
        position=np.nonzero(D)
        #print position
        position=position[0]
        secnd_chunk=0x00
        secnd_position=0x00
        frst_chunk=D[position[1]]
        frst_position=(position[1]/8)*8+7-(position[1]%8)

        if(len(position)==3):
            secnd_chunk=D[position[2]]
            secnd_position=(position[2]/8)*8+7-(position[2]%8)
        Curve_Polynomial=np.array([Curve_len,frst_position,frst_chunk,secnd_position,secnd_chunk],dtype='uint8')
        Curve_Polynomial=self.nparray2str2(Curve_Polynomial)
        return Curve_Polynomial
    
    @cocotb.coroutine
    def Ram_write(self,dut, A, B):

        Ad = BinaryValue()
        Ad.assign(A)
        Bd = BinaryValue()
        Bd.assign(B)
        dut.a_adbus.value = Bd
        dut.a_data_in.value = Ad
        dut.a_w.value=1
        yield RisingEdge(self.dut.clk)
        dut.a_w.value=0
        yield ReadOnly()
        #raise ReturnValue(dut.d.value)



    @cocotb.coroutine
    def Ram_Read(self,dut, A):

        Ad = BinaryValue()
        Ad.assign(A)

        #print Ad, Bd
        dut.a_adbus.value = Ad
        yield RisingEdge(self.dut.clk)
        yield ReadOnly()
        raise ReturnValue(dut.a_data_out.value)


    @cocotb.coroutine
    def wait(self,dut):
        yield RisingEdge(self.dut.clk)
        yield RisingEdge(self.dut.clk)
        yield ReadOnly()

    @cocotb.coroutine
    def trigger(self,dut):
        yield RisingEdge(self.dut.clk)
        dut.command_scalar_multiplication.value=1
        yield RisingEdge(self.dut.clk)
        dut.command_scalar_multiplication.value=0
        yield ReadOnly()


    @cocotb.coroutine
    def start(self,dut):
        yield RisingEdge(self.dut.clk)
        dut.start_operation.value=1
        yield RisingEdge(self.dut.clk)
        dut.start_operation.value=0
        yield ReadOnly()

    @cocotb.coroutine   
    def interupt(self,dut):
        while not dut.interupt_scalar_mul.value:
            yield RisingEdge(self.dut.clk)


@cocotb.test()
def test_ks(dut):
    tb=Scalar_mul(dut)
    ###113 bit_curve_data
    '''Polynomial1 = '020000000000000000000000000201'
    X='9d73616f35f4ab1407d73562c10f'
    Y='a52830277958ee84d1315ed31886'
    a='3088250ca6e7c7fe649ce85820f7'
    Private_key='17' '''
    
    ## 131 bit_curve_data
    Polynomial1 = '080000000000000000000000000000010d'
    a='07a11b09a76b562144418ff3ff8c2570b8'
    X='0081baf91fdf9833c40f9c181343638399'
    Y='078c6e7ea38c001f73c8134b1b4ef9e150'
    Private_key='179759060796de1' 
    
    ###163 bit_curve
    '''Polynomial1 = '0800000000000000000000000000000000000000c9'
    a='1'
    X='02fe13c0537bbc11acaa07d793de4e6d5e5c94eee8'
    Y='0289070fb05d38ff58321f2e800536d538ccdaa3d9'
    Private_key='177378932de'
    '''
    
    ###233 bit_curve
    Polynomial1 = '20000000000000000000000000000000000000004000000000000000001'
    a='0'
    X='17232ba853a7e731af129f22ff4149563a419c26bf50a4c9d6eefad6126'
    Y='1db537dece819b7f70f555a67c427a8cd9bf18aeb9b56e0c11056fae6a3'
    Private_key='17'
    
    
    Zero='0'
    P=Private_key
    
    Polynomial=tb.Curve_Calculation(Polynomial1)
    Polynomial=tb.str2nparray(Polynomial)
    X=tb.str2nparray(X)
    Y=tb.str2nparray(Y)
    a=tb.str2nparray(a)
    Zero=tb.str2nparray(Zero)
    Private_key=tb.str2nparray(Private_key)
    A = np.array([X,Y,a,Polynomial,Zero,Zero,Private_key,X,Y])
    B = np.array([0x03,0x06,0x09,0x14,0x15,0x16,0x17,0x19,0x1c],dtype='uint8') 


    D = np.array([0x21,0x27],dtype='uint8')
  
    cocotb.fork(Clock(dut.clk, 10).start())
    #n = input('ENTER THE NUMBER OF BITS')
    
    
    print "Time in",str(datetime.now())
    yield tb.wait(dut)
    for i,j in zip(A,B):
        C = yield tb.Ram_write(dut, i.tostring()[::-1], j.tostring())

    
    yield tb.start(dut)
    yield tb.wait(dut)
    yield tb.wait(dut)
    yield tb.wait(dut)
    yield tb.trigger(dut)

    yield tb.interupt(dut)
    
    Result=np.array([],dtype='uint32')
    count=0

    for i in D:
        Cd = yield tb.Ram_Read(dut,i.tostring())
        Cd = np.fromstring(Cd.buff[::-1], dtype=np.uint32)
        Cd=tb.remove_1(Cd)
        Result=np.append(Result,Cd,axis=0)
    print Result
    
    print "Time Out",str(datetime.now())
        #count+=count
    
    
    field=Binfield(Polynomial1)
    D=field.public_key_gen(X,Y,a,int(P,16))
    print D
    D[0]=field.nparray2str(D[0])
    D[1]=field.nparray2str(D[1])
    X=int(D[0],16)
    Y=int(D[1],16)
    