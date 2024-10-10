const fs = require('fs');
let coefs= [-2.866e-04,-3.703e-04,-4.341e-04,-4.624e-04,-4.369e-04,-3.373e-04,-1.413e-04,1.741e-04,6.319e-04,1.254e-03,
            2.062e-03,3.071e-03,4.296e-03,5.744e-03,7.417e-03,9.311e-03,1.141e-02,1.371e-02,1.616e-02,1.874e-02,
            2.142e-02,2.413e-02,2.684e-02,2.948e-02,3.202e-02,3.438e-02,3.651e-02,3.838e-02,3.993e-02,4.112e-02,
            4.194e-02,4.235e-02];
      coefs =   coefs.map((val,idx)=>Math.round(val*524270)); // 524280 >> 3 = 65535
let another = Array.from(coefs)

for (let q=coefs.length-1; q>=0; q--){
    another.push(coefs[q]);
}
let content='['
let sum=0;
another.forEach((v,idx)=>{
    content +=`${v},`
     sum += v
    })
    console.log(sum)
content += '], shitf right on 3 bits to have 65535 in sum';
fs.writeFileSync('./Koefs.txt',content);


 ;---data area , checksum 524278 or $0007 FFF6 in hex
_TBL DC.W $ff6a,$ff3e,$ff1c,$ff0e,$ff1b,$ff4f,$ffb6
  DC.W $005b,$014b,$0291,$0439,$064a,$08cc,$0bc3,$0f31
  DC.W $1311,$175e,$1c14,$2118,$2661,$2bde,$316b
  DC.W $36f7,$3cf5,$4193,$4668, $4ac5, $4e99
  DC.W $51c6,$5436,$55e4,$56bb,$56bb,$55e4
  DC.W $5436,$51c6, $4e99, $4ac5,$4668, $4193
  DC.W $3cf5,$36f7, $316b, $2bde, $2661, $2118
  DC.W $1c14,$175e,$1311,$0f31,$0bc3,$08cc,$064a
  DC.W $0439,$0291,$014b,$005b,$ffb6,$ff4f,$ff1b,$ff0e
  DC.W $ff1c, $ff3e,$ff6a

;//procedure 32 addition m_Add32
;@ operand A @ operand B
;STACK -8
;----frame, start SP offset:
;0  |3  |7 
;RET| V2 | V1
m_Add32
 #define ma1_V1H $7
 #define ma1_V2H $3
 #define ma1_V1L $9
 #define ma1_V2L $5
 ;load 'A' and add low parts firstly
 LDW X, (ma1_V1L,SP)
 LDW Y, (ma1_V1H,SP)
 ADDW X, (ma1_V2L,SP)
 ;if carry, increment 1 to BH
 JRNC ma1_l_no_c
   INCW Y   ;add 1 when cary from low word
ma1_l_no_c
  ;add high parts
 ADDW Y, (ma1_V2H,SP)
 ;store results
 LDW (ma1_V2L,SP),X
 LDW (ma1_V2H,SP),Y
 RET
