function X = coding4b5b(data)
code5b = zeros(1, 5);

if isequal(data, [0 0 0 0]) == 1        %0
    code5b = [1 1 1 1 0];
elseif isequal(data, [0 0 0 1]) == 1    %1
    code5b = [0 1 0 0 1];
elseif isequal(data, [0 0 1 0]) == 1    %2
    code5b = [1 0 1 0 0];    
elseif isequal(data, [0 0 1 1]) == 1    %3
    code5b = [1 0 1 0 1];
elseif isequal(data, [0 1 0 0]) == 1    %4
    code5b = [0 1 0 1 0];
elseif isequal(data, [0 1 0 1]) == 1    %5
    code5b = [0 1 0 1 1];   
elseif isequal(data, [0 1 1 0]) == 1    %6
    code5b = [0 1 1 1 0];       
elseif isequal(data, [0 1 1 1]) == 1    %7
    code5b = [0 1 1 1 1];
    
elseif isequal(data, [1 0 0 0]) == 1    %8
    code5b = [1 0 0 1 0];   
elseif isequal(data, [1 0 0 1]) == 1    %9
    code5b = [1 0 0 1 1];   
elseif isequal(data, [1 0 1 0]) == 1    %10
    code5b = [1 0 1 1 0];   
elseif isequal(data, [1 0 1 1]) == 1    %11
    code5b = [1 0 1 1 1];
elseif isequal(data, [1 1 0 0]) == 1    %12
    code5b = [1 1 0 1 0];   
elseif isequal(data, [1 1 0 1]) == 1    %13
    code5b = [1 1 0 1 1];   
elseif isequal(data, [1 1 1 0]) == 1    %14
    code5b = [1 1 1 0 0];   
elseif isequal(data, [1 1 1 1]) == 1    %15
    code5b = [1 1 1 0 1];    
end

X = code5b;
end