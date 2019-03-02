function[Dates, Returns] = readStock(fileName)

options = detectImportOptions(fileName);
T = readtable(fileName, options);
Dates = T(:,1);
Values = T(:,2);
Dates = table2array(Dates);
Values = table2array(Values);

ValuesArray = Values;

Returns = zeros(size(ValuesArray));

for value = 1:size(ValuesArray)
    if value == 1
        Returns(value, :) = ValuesArray(value, :);
    else
        Returns(value, :) = (ValuesArray(value, :) / ValuesArray(value-1, :))-1;
    end
end

end