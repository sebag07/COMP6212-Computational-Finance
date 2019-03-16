function [Dates, Returns] = indexTracker(DatesMap, ReturnsMap, files)

N = length(files);

SampleReturn = ReturnsMap(files(1).name);

SUM = zeros(length(SampleReturn),1);

for i = 1:length(SampleReturn)
    for j = 1:N
        ReturnsList = ReturnsMap(files(j).name);
        ReturnThing = ReturnsList(i);
        SUM(i) = SUM(i)+ReturnThing;
    end
end

Dates= DatesMap(files(1).name);
Returns = SUM/N;

end 