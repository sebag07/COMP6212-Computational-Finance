function GreedyMap = greedySelection(Returns, ReturnsMap, files)

GreedyMap = containers.Map();
N = length(files);


for i=1:N
    FileName = files(i).name;
    ReturnThing = ReturnsMap(FileName);
    Result = zeros(length(Returns),1);

    for j=1:length(Returns)
        Result(j) = abs(Returns(j) - ReturnThing(j));
    end
    
    GreedyMap(FileName)= Result;
end

end