% SLP implementation of the transformation given by the R matrix.
%
% LRP matrices and SLP implementation are taken from the github repo:
% [1] J.-G. Dumas, B. Grenet, C. Pernet, and A. Sedoglavic, 
% “Plinopt: A collection of C++ routines handling linear & bilinear programs,” 
%  https://github.com/jgdumas/plinopt, Jan. 2024.
%
% that refers to the paper: 
% [2] J.-G. Dumas, C. Pernet, and A. Sedoglavic, 
% “A non-commutative algorithm for multiplying 4×4 matrices using 
% 48 non-complex multiplications,” arXiv preprint arXiv:2506.13242, June 16 2025.
%
function R=rational_R(B)

% input B is B 4x4 mBtrix 
% output is R is a 48x1 vector

% Assign the inputs
B11 = B(1,1);  B12 = B(1,2);  B13 = B(1,3);  B14 = B(1,4);
B21 = B(2,1);  B22 = B(2,2);  B23 = B(2,3);  B24 = B(2,4);
B31 = B(3,1);  B32 = B(3,2);  B33 = B(3,3);  B34 = B(3,4);
B41 = B(4,1);  B42 = B(4,2);  B43 = B(4,3);  B44 = B(4,4);

 y16=B11-B14; y17=B31-B34; y18=B32+B33; r6=B22-B42; r15=y16-y17; y21=B43-B41;
 y22=B12+B13; r2=B12+B32; r3=y18-y21; r7=y16+y17; r10=B24-B44+r6; r12=B33+r15-B13;
 r14=B12-B31; r19=B23-y21-B21; r35=y22+y18; r38=B41-B21; r39=B22+B24+y16;
 r40=y22-y18; r42=B11+B31; r44=B41-B31; r47=B22+B41; d48=r19+r35; d49=r7+r10;
 d50=r15-r44; d51=r39-r3; d52=r2+r12; d53=d51-d50; r31=d49-d48; d55=r14+r47;
 r34=d53*2-r31; d57=d52-r14*2; r24=d55*2-r34; r16=r3-d48; r33=r39-d49;
 d61=d50-r40; d62=r14+r42; d63=r39*2-d49; d64=r47-r38; d65=r2-r14; d66=d52-d55;
 d67=d57+r34; d68=r47-r6; d69=d48-r3*2; r8=d52*2-r24; r25=r35-d49+d53+d57;
 r27=r34+d57*2; r45=r10-d53; r20=r33+d65; r13=d65-r3; r18=d63-d69; r9=r42-d57;
 r21=d49+d48; r1=d62-r39; r0=d57-d61; r41=d68-r33; r43=d52-r14; r26=d64-r16;
 r5=d63-r15; r29=d68-r3; r36=d67-r38; r46=d62+r16; r11=r31-d51*2; r17=r40-d69;
 r32=r44-d55; r28=d61-d66; r30=r39-d64; r23=r19+d53+d66; r22=r6+d52-r24;
 r4=d48+d53-d55-r7; r37=d67-r47;

R = zeros(1,48);

R(1)  = r0;  R(2)  = r1;  R(3)  = r2;  R(4)  = r3;
R(5)  = r4;  R(6)  = r5;  R(7)  = r6;  R(8)  = r7;
R(9)  = r8;  R(10) = r9;  R(11) = r10; R(12) = r11;
R(13) = r12; R(14) = r13; R(15) = r14; R(16) = r15;
R(17) = r16; R(18) = r17; R(19) = r18; R(20) = r19;
R(21) = r20; R(22) = r21; R(23) = r22; R(24) = r23;
R(25) = r24; R(26) = r25; R(27) = r26; R(28) = r27;
R(29) = r28; R(30) = r29; R(31) = r30; R(32) = r31;
R(33) = r32; R(34) = r33; R(35) = r34; R(36) = r35;
R(37) = r36; R(38) = r37; R(39) = r38; R(40) = r39;
R(41) = r40; R(42) = r41; R(43) = r42; R(44) = r43;
R(45) = r44; R(46) = r45; R(47) = r46; R(48) = r47;
