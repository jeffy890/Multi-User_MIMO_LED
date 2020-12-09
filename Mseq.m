function X = Mseq(D)
%Generate Mseq

%the weight "w" is defined by the number "D"
switch D
    case 4
        w = [1;0;0;1];
    case 5
        w = [0;1;0;0;1];
    case 6
        w = [1;0;0;0;0;1];
    case 7
        w = [0;0;0;0;0;1;1];
    case 8
        w = [0;1;1;1;0;0;0;1];
    case 9
        w = [0;0;0;0;1;0;0;0;1];
    case 10
        w = [0;0;1;0;0;0;0;0;0;1];
    case 11
        w = [0;1;0;0;1;0;0;1;0;0;1];
    case 12
        w = [1;0;0;1;0;1;0;0;0;0;0;1];
    case 13
        w = [1;0;1;1;0;0;0;0;0;0;0;0;1];
    case 14
        w = [1;1;0;0;0;0;0;0;0;0;0;1;0;1];
    case 15
        w = [1;0;0;0;0;0;0;0;0;0;0;0;0;0;1];
    otherwise
        error('No Infomation    Mseq( 4�`15 )');
end

length = 2^D - 1;
memory = ones(D,1);
m = zeros(length,1);

for x = 1:length
    m(x) = memory(end);
    h0 = mod(w' * memory,2);
    memory(2:end) = memory(1:(end-1));
    memory(1) = h0;
end

m = m';
m(m==0) = -1;
X=m;
end

