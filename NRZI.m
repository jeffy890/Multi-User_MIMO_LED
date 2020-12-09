function X = NRZI(data)
[datalength_v, datalength_h] = size(data);
signal = zeros(1, datalength_h);
pre = 0;
for i=1:datalength_h
    if data(i) == 1
        if pre == 1
            signal(i) = 0;
            pre = 0;
        elseif pre == 0
            signal(i) = 1;
            pre = 1;
        end
    elseif data(i) == 0
        signal(i) = pre;
    end
end
X = signal;
end