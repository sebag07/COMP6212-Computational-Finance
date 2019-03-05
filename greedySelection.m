function indexMap = greedySelection(Returns, ReturnsMap)

N = 30;

errors = zeros(N,1);

for i=1:N
    ReturnThing = ReturnsMap(:,i);
    errors(i) = immse(Returns, ReturnThing);
end

[~, indexes] = sort(errors, 'ascend');

indexMap = indexes(1:6);

end