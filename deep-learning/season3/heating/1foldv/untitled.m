net = feedforwardnet(10);
[net, tr] = train(net, inputs,targets);
output = net (inputs(:,5))
