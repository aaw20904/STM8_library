float DigFil(invar, initval, setic)
float invar, initval; int setic;
/******************************************************************************/
/* Filter Solutions Version 2014                 Nuhertz Technologies, L.L.C. */
/*                                                            www.nuhertz.com */
/*                                                            +1 602-279-2448 */
/* 64 Tap Low Pass Kaiser                                                     */
/* Finite Impulse Response                                                    */
/* Sample Frequency = 2.500 KHz                                               */
/* Standard Form                                                              */
/* Arithmetic Precision = 4 Digits                                            */
/*                                                                            */
/* Pass Band Frequency = 50.00 Hz                                             */
/*                                                                            */
/* Kaiser Constant = 5.000                                                    */
/*                                                                            */
/******************************************************************************/
/*                                                                            */
/* Input Variable Definitions:                                                */
/* Inputs:                                                                    */
/*   invar    float       The input to the filter                             */
/*   initvar  float       The initial value of the filter                     */
/*   setic    int         1 to initialize the filter to the value of initvar  */
/*                                                                            */
/* Option Selections:                                                         */
/* Standard C;   Initializable;            Internal States;   Optimized;      */
/*                                                                            */
/* There is no requirement to ever initialize the filter.                     */
/* The default initialization is zero when the filter is first called         */
/*                                                                            */
/******************************************************************************/
/*                                                                            */
/* This software is automatically generated by Filter Solutions               */
/* no restrictions from Nuhertz Technologies, L.L.C. regarding the use and    */
/* distributions of this software.                                            */
/*                                                                            */
/******************************************************************************/

{
    float sumnum=0.0; int i=0;
    static float states[63] = {0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
    static float znum[32] = {
        -2.866e-04,-3.703e-04,-4.341e-04,-4.624e-04,-4.369e-04,-3.373e-04,-1.413e-04,1.741e-04,6.319e-04,1.254e-03,
        2.062e-03,3.071e-03,4.296e-03,5.744e-03,7.417e-03,9.311e-03,1.141e-02,1.371e-02,1.616e-02,1.874e-02,
        2.142e-02,2.413e-02,2.684e-02,2.948e-02,3.202e-02,3.438e-02,3.651e-02,3.838e-02,3.993e-02,4.112e-02,
        4.194e-02,4.235e-02
    };
    if (setic==1){
        for (i=0;i<63;i++) states[i] = initval;
        return initval;
    }
    else{
        for (i=0;i<63;i++){
            sumnum += states[i]*znum[i<32?i:63-i];
            if (i<62) states[i] = states[i+1];
        }
        states[62] = invar;
        sumnum += states[62]*znum[0];
        return sumnum;
    }
}
