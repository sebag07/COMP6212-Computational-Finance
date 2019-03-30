function result = func(x, mu, sigma)
    distance = (x-mu)*inv(sigma)*(x-mu)';
    result = sqrt(distance);
end