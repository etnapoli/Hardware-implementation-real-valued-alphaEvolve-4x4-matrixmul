% SLP implementation of the transformation given by the P matrix.
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
function C=rational_P(P)
% input P is a 48x1 vector 
% output is C is a 4x4 matrix

% assign the inputs
p0  = P(1);  p1  = P(2);  p2  = P(3);  p3  = P(4);
p4  = P(5);  p5  = P(6);  p6  = P(7);  p7  = P(8);
p8  = P(9);  p9  = P(10); p10 = P(11); p11 = P(12);
p12 = P(13); p13 = P(14); p14 = P(15); p15 = P(16);
p16 = P(17); p17 = P(18); p18 = P(19); p19 = P(20);
p20 = P(21); p21 = P(22); p22 = P(23); p23 = P(24);
p24 = P(25); p25 = P(26); p26 = P(27); p27 = P(28);
p28 = P(29); p29 = P(30); p30 = P(31); p31 = P(32);
p32 = P(33); p33 = P(34); p34 = P(35); p35 = P(36);
p36 = P(37); p37 = P(38); p38 = P(39); p39 = P(40);
p40 = P(41); p41 = P(42); p42 = P(43); p43 = P(44);
p44 = P(45); p45 = P(46); p46 = P(47); p47 = P(48);


q5=p44-p34; q6=p20+p33-p41; q8=p24-p32; q15=p13+p29-p3; q17=p15+p40+p12*2+p11;
 k71=(p29+p26)*2; k69=(p41-p30)*2; k68=(p20-p1)*2; k67=(p46-p13)*2;
 k66=(p32-p28)/2; k65=(p0+p44)/2; k63=(p39+p30+p1)/2; k60=(p26+p46+p16)/2;
 q19=q8-p28-p8; q21=q5-p45; q26=p18-p31-p5*2-k68-k67; q27=p47+k66; q30=p2*2+q15+q6;
 k56=(q15-q6)/2; q31=k60-k63; q37=p5-p18-p22*2-q17+q19; q42=(p37-p43)*2-k56*4;
 q44=q8+q21-q26; q46=k63+q27+k60-q30/2; z43=(p42+q46+k65)/2; z42=(p38+q46)/2;
 z41=(p36+p22-p37-q31+k56)/2; z40=(p0-p27-q5-q17*2+q19-q42)/8;
 z39=(p25+p45+(p12-p22)*2+q42)/4; z38=(p23+(-p12-p22)*2+q44)/4;
 z37=(q26-p21-p11-k71-k69-(p15+q21)*2)/8; z36=(p17+q37)/4; z35=(p14-k65-q27+q30)/4;
 z34=(p9+p43-p12+k56+q31)/2; z33=(p7+p15+k69)/4; z32=(p6+k66-p2)/2;
 q52=(p4+q44)/4+z37; z31=z35+z40; z30=z40-z35; q55=(p5+k68-p10)/4-z32; q56=z37-z31;
 C42=z36-z30; z23=z34-z30; C32=z30-z32; C12=z32+z31; q57=z31+z42; C22=z31-z36;
 q58=(p19+k67+q37)/4-q57; C11=z34-q57; C34=q52-q55+z23; C31=z42+z23;
 q59=(p35+k71-p40)/4+q56; C14=z34+q55+q56; z18=z43+C22; z16=z43+C42;
 C33=z39-z37-q58; C13=q58-z37-z38; C44=z33+q52+z18; C41=z18-z41; C43=q59-z41-z39;
 C23=z41+z38+q59; C24=z33+z37+z16; C21=z41+z16;
 
C = [ C11 C12 C13 C14;
      C21 C22 C23 C24;
      C31 C32 C33 C34;
      C41 C42 C43 C44 ];
