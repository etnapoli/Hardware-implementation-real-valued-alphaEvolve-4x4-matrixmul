% SLP implementation of the transformation given by the L matrix.
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
function L=rational_L(A)

% input A is a 4x4 matrix 
% output is L is a 48x1 vector

% assign the inputs
A11 = A(1,1);  A12 = A(1,2);  A13 = A(1,3);  A14 = A(1,4);
A21 = A(2,1);  A22 = A(2,2);  A23 = A(2,3);  A24 = A(2,4);
A31 = A(3,1);  A32 = A(3,2);  A33 = A(3,3);  A34 = A(3,4);
A41 = A(4,1);  A42 = A(4,2);  A43 = A(4,3);  A44 = A(4,4);

 x16=A13+A24;
 x17=A14+A23;
 x18=A12-A21;
 x19=A31-A42;
 x20=A33+A44;
 x21=A34+A43;
 x22=A22-A11;
 x23=A32-A41;
 x24=A13-A23;
 x25=A32-A42;
 x26=A33+A43;
 x27=A31-A41;
 x28=A34+A44;
 x29=A12+A22;
 x30=A11+A21;
 x31=A14-A24;
 x32=x23-x19;
 x33=x16+x17;
 x34=x20-x21;
 x35=x22-x18;
 x36=x20+x21;
 x37=x18+x22;
 x38=x16-x17;
 x39=x19+x23;
 x40=x29+x30;
 x41=x25-x27;
 x42=x26-x28;
 x43=x24+x31;
 l8=x32-x43;
 x45=A33-A43;
 x46=A31+A41;
 x47=A13+A23;
 l34=x34+x40;
 l27=x33-x41;
 x50=A32+A42;
 x51=A12-A22;
 x52=A14+A24;
 l24=x42-x35;
 x54=A34-A44;
 x55=A11-A21;
 x56=x17+x18;
 x57=x34-x35;
 x59=x37+x32;
 x60=x38+x46+x50;
 l38=x29-x25;
 x63=x36+x33;
 l2=x26-x24;
 x66=x36-x33;
 l6=x28-x31;
 l36=x25+x29;
 l12=x24+x26;
 x71=x34+x35;
 x72=x39-x38;
 x73=x16-x22;
 l22=x28+x31;
 x75=x52-x39-x47;
 x76=x38+x39;
 x77=x37-x32;
 x78=x55+x36-x51;
 l9=x27+x30;
 x80=x45+x54-x37;
 l42=x30-x27;
 x82=x19+x20;
 x83=x21+x23;
 l0=l27-x80;
 l1=x27-x55;
 l3=x42-x33;
 l4=l24+x60;
 l5=x57-x76;
 l7=x57+x76;
 l10=x71+x72;
 l11=x56+x83;
 l13=x47-x26;
 l14=l42-l2;
 l15=x72-x71;
 l16=x40+x32;
 l17=x77-x66;
 l18=x56-x83;
 l19=x66+x77;
 l20=x24-x45;
 l21=x73+x82;
 l23=x78-l8;
 l25=l27+x80;
 l26=x29+x50;
 l28=x78+l8;
 l29=x28+x52;
 l30=x25+x51;
 l31=x73-x82;
 l32=x60-l24;
 l33=x34-x43;
 l35=x63-x59;
 l37=l36+l22;
 l39=x35-x41;
 l40=x59+x63;
 l41=x31+x54;
 l43=l12+l9;
 l44=l34+x75;
 l45=l34-x75;
 l46=x46-x30;
 l47=l6-l38;

L = zeros(1,48);

L(1)  = l0;  L(2)  = l1;  L(3)  = l2;  L(4)  = l3;
L(5)  = l4;  L(6)  = l5;  L(7)  = l6;  L(8)  = l7;
L(9)  = l8;  L(10) = l9;  L(11) = l10; L(12) = l11;
L(13) = l12; L(14) = l13; L(15) = l14; L(16) = l15;
L(17) = l16; L(18) = l17; L(19) = l18; L(20) = l19;
L(21) = l20; L(22) = l21; L(23) = l22; L(24) = l23;
L(25) = l24; L(26) = l25; L(27) = l26; L(28) = l27;
L(29) = l28; L(30) = l29; L(31) = l30; L(32) = l31;
L(33) = l32; L(34) = l33; L(35) = l34; L(36) = l35;
L(37) = l36; L(38) = l37; L(39) = l38; L(40) = l39;
L(41) = l40; L(42) = l41; L(43) = l42; L(44) = l43;
L(45) = l44; L(46) = l45; L(47) = l46; L(48) = l47;
