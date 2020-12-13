function [data] = preprocessing(bit)
bitlength = 2^bit;

% make Mseq signal first
data = Mseq(bit);
data(bitlength) = -1;

% 4b5b coding
data = reshape(data, [4, bitlength/4]);
data = (data+1)/2;

data_5b = zeros(bitlength/4, 5);

for i=1:(bitlength/4)
    data_4b = data';
    data_5b(i,:) = coding4b5b(data_4b(i,:));
end
data_5b = data_5b';
data_5b = reshape(data_5b, [1, bitlength*5/4]);

% nrzi coding
data = NRZI(data_5b);
data = (data*2)-1;