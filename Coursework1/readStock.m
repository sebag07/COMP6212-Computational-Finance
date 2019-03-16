function[Dates, Returns] = readStock(fileName)

options = detectImportOptions(fileName);
T = readtable(fileName, options);
Dates = T(:,1);
Values = T(:,2);
Dates = table2array(Dates);
Values = table2array(Values);

ValuesArray = Values;

Returns = zeros(size(ValuesArray));

for value = 2:size(ValuesArray)
        Returns(value, :) = (ValuesArray(value, :) / ValuesArray(value-1, :))-1;
end

end